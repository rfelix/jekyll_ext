require File.join(File.dirname(__FILE__), '..', 'aop', 'aop.rb')
require 'stringio'

def catch_output
  orig = $stdout
  fake = StringIO.new
  $stdout = fake
  begin
    yield
  ensure
    $stdout = orig
  end
  fake.string
end

class GuineaPig
end

def get_output_from_eat
  catch_output { GuineaPig.new.eat }
end

def get_output_from_feed(*food)
  catch_output { GuineaPig.new.feed(*food) }
end

describe AOP do
  before(:each) do
    # Reset intercepted methods
    AOP.instance_variable_set(:@intercepted_methods, nil)
    # Clean GuineaPig class
    class GuineaPig
      def eat
        print "food"
        "food"
      end
      
      attr_reader :food
      def feed(*food)
        @food = food
      end
    end
  end
  
  context "#before" do
    it "must display 'eat some food'" do
      AOP.before(GuineaPig, :eat) { print "eat some " }
      get_output_from_eat.should == "eat some food"
    end
   
    it "must display 'eat some food' with 2 before blocks " do
      AOP.before(GuineaPig, :eat) { print "eat " }
      AOP.before(GuineaPig, :eat) { print "some " }      
      get_output_from_eat.should == "eat some food"
    end
    
    it "must have access to the instance and the arguments passed to the original method" do
      AOP.before(GuineaPig, :feed) { |instance, args|
        args.each { |arg| print "#{arg} " }
        raise "food instance variable should be nil" unless instance.food.nil?
      }
      get_output_from_feed('apple', 'orange').should == "apple orange "
    end
  end
  
  context "#after" do
    it "must display 'food must be eaten'" do
      AOP.after(GuineaPig, :eat) { print " must be eaten" }
      get_output_from_eat.should == "food must be eaten"
    end
   
    it "must display 'food must be eaten' with 2 after blocks " do
      AOP.after(GuineaPig, :eat) { print " must" }
      AOP.after(GuineaPig, :eat) { print " be eaten" }      
      get_output_from_eat.should == "food must be eaten"
    end
    
    it "must have access to the instance and the arguments passed to the original method" do
      AOP.after(GuineaPig, :feed) { |instance, args|
        args.each { |arg| print "#{arg} " }
        instance.food.each { |food| print "#{food} " }
      }
      get_output_from_feed('apple', 'orange').should == "apple orange apple orange "
    end
  end
  
  context "#around" do
    it "must display 'eat food now'" do
      AOP.around(GuineaPig, :eat) do |instance, args, proceed|
        print "eat "
        proceed.call
        print " now"
      end
      get_output_from_eat.should == "eat food now"
    end
    
    it "must display 'must eat food right now' with 2 after blocks" do
      AOP.around(GuineaPig, :eat) do |instance, args, proceed|
        print "eat "
        proceed.call
        print " right"
      end
      
      AOP.around(GuineaPig, :eat) do |instance, args, proceed|
        print "must "
        proceed.call
        print " now"
      end
      
      get_output_from_eat.should == "must eat food right now"
    end
    
    it "must return 'food please" do
      AOP.around(GuineaPig, :eat) do |instance, args, proceed|
        proceed.call + " please"
      end
      catch_output { GuineaPig.new.eat.should == "food please" }
    end
    
    it "must return 'bring me food pretty please" do
      AOP.around(GuineaPig, :eat) do |instance, args, proceed|
        "me " + proceed.call + " pretty"
      end
      
      AOP.around(GuineaPig, :eat) do |instance, args, proceed|
        "bring " + proceed.call + " please"
      end
      
      catch_output { GuineaPig.new.eat.should == "bring me food pretty please" }
    end
    
    it "must return 'diet' when aborted" do
      AOP.around(GuineaPig, :eat) do |instance, args, proceed, abort|
        proceed.call
      end
      
      AOP.around(GuineaPig, :eat) do |instance, args, proceed, abort|
        abort.call("diet")
        proceed.call        
      end      
      
      GuineaPig.new.eat.should == "diet"
    end
    
    it "must have access to the instance and the arguments passed to the original method" do
      AOP.around(GuineaPig, :feed) { |instance, args, proceed, abort|
        args.each { |arg| print "#{arg} " }
        proceed.call
        instance.food.each { |food| print "#{food} " }
      }
      get_output_from_feed('apple', 'orange').should == "apple orange apple orange "
    end
  end
end