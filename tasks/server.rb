namespace :server do
  task :key => 'server/server.key'
  task :req => 'server/server.req'
  
  desc "Produce a web certificate signed by the root CA"
  task :sign => 'server/server.crt'

  desc "Bundle up the web key, certificate, and root CA"
  task :bundle => 'server.tar.bz2'

  directory 'server'
  
  file 'server/server.key' => 'server' do
    sh "openssl genrsa -out server/server.key 2048"
  end

  file 'server/server.csr' => 'server/server.key' do
    answers = {
      c: 'US',
      st: 'Florida', 
      l: 'Miami', 
      o: '', 
      ou: 'Riak Ruby client', 
      cn: 'localhost', 
      email: 'bryce@basho.com',
      pass: '',
      company: '',
    }
    sh "echo \"#{answers.values.join "\n"}\" | openssl req -config openssl.cnf -new -key server/server.key -out server/server.csr"
  end

  file 'server/server.crt' => [
                               'server/server.csr', 
                               'ca/ca.crt', 
                               'ca/ca.key', 
                               'index.txt', 
                               'index.txt.attr',
                               'serial',
                               'newcerts'
                              ] do
    days = 3650
    sh "yes | openssl ca -config openssl.cnf -days #{days} -in server/server.csr -cert ca/ca.crt -key ca/ca.key -out server/server.crt"
  end

  file 'server.tar.bz2' => ['server/server.key', 'server/server.crt', 'ca/ca.crt'] do |t|
    sh "tar jcf server.tar.bz2 #{t.prerequisites.join ' '}"
  end

  file 'server.iso' => ['server/server.key', 'server/server.crt', 'ca/ca.crt'] do |t|
    sh "mkisofs --allow-lowercase -o server.iso #{t.prerequisites.join ' '}"
  end

  desc "Destroy the server key, request, cert, and bundle"
  task :clean do
    sh 'rm -rf server'
    sh 'rm -f server.tar.bz2'
  end
end