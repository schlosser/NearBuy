# b14s
The DevFest Battle of the Hacks Project

## Server Development

```bash
cd server
virtualenv --no-site-packages .
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
