# ChatGPT streaming

## Usage
Install redis
```
brew install redis
```
Add User and Chat information on Rails Console
```
user = User.create(email: 'test@example.com', password: 'password', password_confirmation: 'password')
Chat.create(user: user)
```
Run
```
bin/dev
```
Visit
```
http://lodcalhost:3000/chats/1
```
