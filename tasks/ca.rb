namespace :ca do
  task :key => 'ca/ca.key'

  task :req => 'ca/ca.csr'

  desc "Produce a self-signed CA certificate"
  task :sign => 'ca/ca.crt'

  directory 'ca'

  file 'ca/ca.key' => 'ca' do
    sh "openssl genrsa -out ca/ca.key 2048"
  end

  file 'ca/ca.csr' => 'ca/ca.key' do
    answers = {
      c: 'US', 
      st: 'Florida', 
      l: 'Miami', 
      o: '', 
      ou: 'Riak Ruby Client', 
      cn: 'CA', 
      email: 'bryce@basho.com',
      pass: '',
      company: '',
    }
    sh "echo \"#{answers.values.join "\n"}\" | openssl req -config openssl.cnf -new -key ca/ca.key -out ca/ca.csr"
  end

  file 'ca/ca.crt' => 'ca/ca.csr' do
    sh "openssl x509 -req -days 3650 -in ca/ca.csr -out ca/ca.crt -signkey ca/ca.key"
  end

  desc "Destroy the CA key, request, and certificate"
  task :clean do
    sh 'rm -rf ca'
  end
end
