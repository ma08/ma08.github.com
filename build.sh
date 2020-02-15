jekyll build -d ../dep
sed -i '2 s/^.*$/baseurl: "\/~skakarla"/' _config.yml  
sed -i '3 s/^.*$/url: "http:\/\/cse\.iitkgp\.ac\.in\/~skakarla\/\"/' _config.yml  
jekyll build -d ../deployment 
sed -i '2 s/^.*$/baseurl: ""/' _config.yml  
sed -i '3 s/^.*$/url: "http:\/\/ma08\.github\.io"/' _config.yml  
#find ../dep -type f  -name '*html' -printf '%p ' | xargs sed -i '1s/^/<base href=\"http:\/\/cse\.iitkgp\.ac\.in\/~skakarla\/\">\n /'
#find ../dep -type f  -name '*html' -printf '%p ' | xargs sed -i 's/\"\//\"/g'
#find ../dep -type f  -name '*html' -printf '%p ' | xargs sed -i "s/'\//'/g"
cd ../deployment/
git add -A
git commit -m "$1"
git push origin master 
cd ..
rm -rf public_html/*
echo your passowrd| sshfs skakarla@cse.iitkgp.ac.in:/public_html public_html -o workaround=rename -o password_stdin
rm -rf public_html/*
cp -rf dep/* public_html/
sleep 5
fusermount -u public_html
#git config credential.helper store
