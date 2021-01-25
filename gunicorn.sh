NAME='inventory'                                      # Name of the application
DJANGODIR=/media/main_storage/anup/inventory-management/   # Django project directory
SOCKFILE=/media/main_storage/anup/inventory-management/run/gunicorn_jalpa.sock  # we will communicte using this unix socket
USER=nsdev # the user to run as
GROUP=nsdev # the group to run as
NUM_WORKERS=3                                       # how many worker processes should Gunicorn spawn
DJANGO_SETTINGS_MODULE=core.settings     # which settings file should Django use
DJANGO_WSGI_MODULE=core.wsgi             # WSGI module name
echo "Starting $NAME as `whoami`"
LOG=/media/main_storage/anup/inventory-management/logs/inventory.log

# Activate the virtual environment

cd $DJANGODIR
source /media/main_storage/anup/venvInventory/activate
# /home/nsdev/.virtualenvs/image-classifier/bin/activate
export DJANGO_SETTINGS_MODULE=$DJANGO_SETTINGS_MODULE
export PYTHONPATH=$DJANGODIR:$PYTHONPATH

# Create the run directory if it doesn't exist

RUNDIR=$(dirname $SOCKFILE)
test -d $RUNDIR || mkdir -p $RUNDIR

# Start your Django Unicorn
# Programs meant to be run under supervisor should not daemonize themselves (do not use --daemon)

exec gunicorn ${DJANGO_WSGI_MODULE}:application \
         --name $NAME \
           --workers $NUM_WORKERS \
             --user=$USER --group=$GROUP \
               --bind=unix:$SOCKFILE \
                 --log-level=debug \
                   --log-file=$LOG
