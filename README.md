# 2nd_degree_finder

A simple script that finds posts from your 2nd (or 3rd) degree connections in your LinkedIn feed, that a 1st degree connection engaged on. This creates a list of URLs that it visits, allowing you to offer insights on them, and get you more visibility with people outside your network. 

# To use
You'll need to install Ruby from rubyinstaller.org if you haven't already. 

Then you'll need to install the Watir gem by typing "gem install watir"

Finally, set up your username and password in the example login.json file. Don't share that info with anyone btw :) 

Run the script from the Ruby Command Prompt (which comes as part of a Ruby install) by typing "ruby 2nd_degree_posts.rb" 

Once it's done collecting urls (which it'll stop at 25) it'll go to the first one, allowing you to engage on the post if you want. When you're done with that post, go back to the Ruby Command Prompt where it will say "Press Enter to continue" and it'll go to the next post. 
