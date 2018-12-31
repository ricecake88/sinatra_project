# Specifications for the Sinatra Assessment

Specs:
- [x] Use Sinatra to build the app
  Controllers are based on Sinatra
- [x] Use ActiveRecord for storing information in a database
  Models are all based on ActiveRecord
- [x] Include more than one model class (e.g. User, Post, Category)
  Have three models - budget, category, expense and user
- [x] Include at least one has_many relationship on your User model (e.g. User has_many Posts)
  Expense has many categories
- [x] Include at least one belongs_to relationship on another model (e.g. Post belongs_to User)
  Budget belongs to a category
- [x] Include user accounts with unique login attribute (username or email)
  Has a signup page for different logins and each person has their own related information
- [x] Ensure that the belongs_to resource has routes for Creating, Reading, Updating and Destroying
  The Category resource can be created, read, updated and destroyed. I did change the interface a bit to make it more user friendly, so one can modify and add a category name at the same time. Deletion would be a separate page.
- [x] Ensure that users can't modify content created by other users
  Only content associated to user can be seen
- [x] Include user input validations
  Check that input by user exists or is valid - for each expense, budget, category added.
- [x] BONUS - not required - Display validation failures to user with error message (example form URL e.g. /posts/new)
- [ ] Your README.md includes a short description, install instructions, a contributors guide and a link to the license for your code

Confirm
- [x] You have a large number of small Git commits
  Most commits after the beginning are very small as I learned as I would sometimes forget at the beginning to commit when I got deep down my rabbit hole. I learned my lesson and as I worked on the project I would commit often as soon as I had something.
- [x] Your commit messages are meaningful
  Most commit messages are short and to the point if changes were small. Some times bigger changes would have more details and other times less.
- [x] You made the changes in a commit that relate to the commit message
  Am not fully sure I completed this correctly - most commits I definitely tried grouping the right changes together. Other times, I may have included a file that did not have the right changes and made a more generic comment on the commit message. But most checkouts definitely fit the commit
- [x] You don't include changes in a commit that aren't related to the commit message
  Comment above applies
