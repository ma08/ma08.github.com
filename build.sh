jekyll build -d ../<githubrepo folder>#Put the generated site
jekyll build -d ../<uni webpagefolder>#Put the generated site 
find <uni webpagefolder> -type f  -name '*html' -printf '%p ' | xargs sed -i '1s/^/<base href=\"http:\/\/cse\.iitkgp\.ac\.in\/~skakarla\/\">\n /'
find <uni webpagefolder> -type f  -name '*html' -printf '%p ' | xargs sed -i 's/\"\//\"/g'
find <uni webpagefolder> -type f  -name '*html' -printf '%p ' | xargs sed -i "s/'\//'/g"
cd ../<githubrepo folder>
git add -A #staging the files
git commit -m "$1" #Took the commit message as an argument to the script
git push origin master #pushing it to github 
cd ..
rm -rf <mount dir>/* #Deleting the old stuff from the mount folder
#Now comes the fancy stuff. I mount my webpage host folder using sshfs on the <mount dir> which is a local folder.
#This folder should always be empty before mounting
#The echo is to give the password to the password_stdin. I know it's bad to store the password as plain text in a file. So spare me the vile.
echo <your smartass password here> | sshfs skakarla@cse.iitkgp.ac.in:/public_html <mount dir> -o workaround=rename -o password_stdin
#Here onwards changes in <mount dir> get reflected on the actual hosting folder in the server.
rm -rf <mount dir>/* #Deleting the old stuff from server
cp -rf <uni webpage folder>/* <mount dir>/ #Copying the new stuff into the server
sleep 5 #This is put in to allow the copy to complete I am correct.
#Without the sleep the script was trying to unmount without waiting for the copying to finish
fusermount -u <mount dir> #Unmount
