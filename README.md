# b14s
The DevFest Battle of the Hacks Project

## Server Development

#### First Time Setup

```
mv config/example.secrets.py config/secrets.py
```

Then paste in the API keys.

##### Developing

```bash
cd server
virtualenv --no-site-packages .
source bin/activate
pip install -r requirements.txt
python app.py [debug]
```

## Server Deployment

#### First Time Setup

```bash
git remote add deploy root@b14s.schlosser.io:~/b14s.git
```

#### To Deploy

```bash
git push deploy master
```

## Team

Anshul Gupta
Matt Piccolella
Emily Pries
Dan Schlosser
