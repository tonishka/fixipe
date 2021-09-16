# fixipe
Scans and fixes recipes - the Orbital Project of team bananix 
Note: fixipeBot is live! Go check it out at [here.](t.me/fixipeBot)
## Project Scope
We hope to make regular recipes customisable based on a user’s specific needs/restrictions.

## Motivation
Finding the perfect recipe is not always easy, but for people with allergies and/or other dietary restrictions, it can be a nightmare. They often spend more time than necessary on Google or buying extra cookbooks, only to end up with a recipe distantly related to what they were originally looking for - or one whose ingredients are too hard to find. As a result, such people may abandon this process completely, thus having wasted their time for a fruitless outcome.

## Aim
The objective of this project is to make regular recipes customisable according to a user’s particular dietary needs and preferences. We hope to make this process simple, efficient, and quick - just a quick scan and the user is presented with a host of options. This product is not just a one-time solution - users can store all their recipes so that they never have to run around looking for it again.
## How the app works
- Firstly, users will have to create an account, and then take a quiz to create a food profile based on their dietary restrictions. 

- Upon login, they can take a picture of any recipe, and ingredients that they cannot eat will automatically be substituted for alternatives that are easily accessible in any local supermarket. This modified recipe will attempt to preserve the taste of the original food item as much as possible.

- Users can then save these modified recipes to their app for later use so that they do not have to scan the recipe again and can save time accordingly.

## Core Features

1. User SignUp/Account Creation: Before being able to use the app, users will have to create an account by entering a username, password and email address.
   - Key Components: Swift UI and database handling

2. Quiz to determine their Food Profile: Upon creating their account, users will have to then take a quiz to identify their diet, which consists of various options such as Vegan, Gluten-Free, Dairy-Free, Low Sugar etc.
   - Key Components: Swift UI and database handling

3. Login: existing users will have to enter their username/email address and password to access their account.
   - Key Components: Swift UI and database handling

4. Homepage: Upon logging in, users will be directed to the homepage which shows all of their existing saved recipes. A tab function at the bottom will allow them to access the other key features of their account, which are Scan Recipe and User Profile.
   - Key Components: Swift UI and database handling

5. Scanning a Recipe: Users will be given the option of taking/choosing a photo from their existing library of a recipe. This recipe will get modified automatically to accommodate their diet, and they will have the option to save or delete the recipe.
   - Key Components: Swift UI, database handling, and text recognition.
   - Text recognition is used to identify keywords and alter them accordingly.

6. User Profile: This will allow the users to keep track of their username/password, as well as log out from the app.
   - Key Components: Swift UI and database handling


