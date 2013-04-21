# -*- encoding: utf-8 -*-
$:.push('lib')
require "glick"

Gem::Specification.new do |s|
  s.name     = "glick"
  s.version  = Glick::VERSION.dup
  s.date     = "2013-04-21"
  s.summary  = "Glicko-2"
  s.email    = "judofyr@gmail.com"
  s.homepage = "https://github.com/judofyr/glick"
  s.authors  = ['Magnus Holm']
  
  s.description = s.summary
  
  s.files         = Dir['{test,lib}/*']
  s.test_files    = Dir['test/**/*'] + Dir['spec/**/*']
end
