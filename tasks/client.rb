namespace :client do
  task key: 'client/client.key'
  task req: 'client/client.req'
  task crl: 'client/client.crl'

  desc "Produce a client cert signed by the root CA"
  task sign: 'client/client.crt'

  directory 'client'

  file 'client/client.key' => 'client' do
    sh "openssl genrsa -out client/client.key 2048"
  end

  file 'client/client.csr' => 'client/client.key' do
    answers = { 
      c: 'US',
      st: 'Florida',
      l: 'Miami',
      o: '',
      ou: 'Riak Ruby client',
      cn: 'certuser',
      email: 'bryce@basho.com',
      pass: '',
      company: '',
    }
    sh "echo \"#{answers.values.join "\n"}\" | openssl req -config openssl.cnf -new -key client/client.key -out client/client.csr"
  end

  file 'client/client.crt' => [
                               'client/client.csr',
                               'ca/ca.crt',
                               'ca/ca.key',
                               'index.txt',
                               'index.txt.attr',
                               'serial',
                               'newcerts'
                              ] do
    days = 3650
    sh "yes | openssl ca -days #{days} -in client/client.csr -cert ca/ca.crt -key ca/ca.key -out client/client.crt"
  end

  file 'client/client.crl' => [
                              'client/client.crt',
                              'ca/ca.key',
                              'ca/ca.crt',
                              'crlnumber'
                              ] do
    sh "rm -f index.txt"
    sh "touch index.txt"
    sh "openssl ca -gencrl -keyfile ca/ca.key -cert ca/ca.crt -out client/client.crl"
    sh "openssl ca -revoke client/client.crt -keyfile ca/ca.key -cert ca/ca.crt"
    sh "openssl ca -gencrl -keyfile ca/ca.key -cert ca/ca.crt -out client/client.crl"
  end

  desc "Destroy the client key, request, cert, and crl"
  task :clean do
    sh 'rm -rf client'
  end
end
