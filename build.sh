jekyll build -d ../dep
jekyll build -d ../deployment 
find ../dep -type f  -name '*html' -printf '%p ' | xargs sed -i '1s/^/<base href=\"http:\/\/cse\.iitkgp\.ac\.in\/~skakarla\/\">\n /'
find ../dep -type f  -name '*html' -printf '%p ' | xargs sed -i 's/\"\//\"/g'
find ../dep -type f  -name '*html' -printf '%p ' | xargs sed -i "s/'\//'/g"
cd ../deployment/
git add -A
git commit -m "$1"
git push origin master 
cd ..
rm -rf public_html/*
echo ARSENAL4eva | sshfs skakarla@cse.iitkgp.ac.in:/public_html public_html -o workaround=rename -o password_stdin
rm -rf public_html/*
cp -rf dep/* public_html/
sleep 5
fusermount -u public_html
#git config credential.helper store
