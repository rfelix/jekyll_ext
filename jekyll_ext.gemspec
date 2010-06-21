# -*- encoding: utf-8 -*-

Gem::Specification.new do |spec|
  spec.name = 'jekyll_ext'
  spec.summary = "Create Jekyll extensions that are local to your blog and that can be shared with others"
  spec.version = File.read(File.dirname(__FILE__) + '/VERSION').strip
  spec.authors = ['Raoul Felix']
  spec.email = 'gems@rfelix.com'
  spec.description = <<-END
      jekyll_ext allows you to extend the Jekyll static blog generator without forking
      and modifying it's codebase. With this code, not only do your extensions live in
      your blog directory, but they can also be shared and reutilized.
    END
  spec.executables = ['ejekyll']
  spec.add_development_dependency('mg')
  spec.files = Dir['lib/*', 'vendor/*', 'bin/*'] + ['Rakefile', 'README.textile']
  spec.homepage = 'http://rfelix.com/2010/01/19/jekyll-extensions-minus-equal-pain/'
end