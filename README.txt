= prerequisites ==============================
- python3 must be installed on your system!

= setup ======================================

$> ./setup.sh

= testing ====================================
- run all unit tests

$> ./test.sh

- run a specific test class

$> ./test.sh ./test.sh ufweb.unittests.views.test_activityviews.TestActivityViews

= pylint checking ====================================
- source code analyzing

$> ./pylint.sh



= start server ===============================
- start default development server

$> ./bin/startup.sh

- start prod server

$> ./bin/startup.sh ./conf/production.ini

- shutdown default development server

$> ./bin/shutdown.sh

- shutdown prod server

$> ./bin/shutdown.sh ./conf/production.ini


= project structure ==========================

ufweb/            # root project folder
    development.ini         # startup config file (dev)
    production.ini          # startup config file (prod)
    setup.sh                # project setup helper script
    test.sh                 # unit test helper script
    startup.sh              # server startup helper script
    ufweb/        # primary package and source code root
        __init__.py         # application startup is here (also REST routes)
        domain/             # domain specific business logic
        static/             # static files (html, css, js, icons, etc.)
        templates/          # MVC views 
        unittests/          # unit test package
        views/              # MVC controllers
    target/                 # generated directory by ./setup.sh
        pyenv/              # generated python3 virtual environment
   
