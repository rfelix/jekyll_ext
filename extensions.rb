require File.join(File.dirname(__FILE__), 'aop', 'aop')

def load_jekyll_extensions(source)
  file = File.join(source, '_extensions', 'jekyll_ext.rb')
  load file
end

