require 'securerandom'
require 'json'

require './tasks/ca'
require './tasks/server'

task :default => 'server/server.crt'

directory 'newcerts'

file 'index.txt' do
  sh 'touch index.txt'
end
file 'index.txt.attr' do
  sh 'touch index.txt.attr'
end
file 'serial' do
  sh "echo #{SecureRandom.random_number 1_000_000} > serial"
end

task :clean => ['ca:clean', 'server:clean'] do
  sh 'rm -f index.txt*'
  sh 'rm -f serial*'
  sh 'rm -f newcerts/*'
end

task :version do
  sh 'openssl version'
end
