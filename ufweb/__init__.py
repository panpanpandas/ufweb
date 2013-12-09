'''uf web service package '''

from pyramid.events import BeforeRender
from pyramid.config import Configurator
from pyramid.session import UnencryptedCookieSessionFactoryConfig

import traceback
import logging
LOG = logging.getLogger(__name__)

def main(global_config, **settings):
    """ This function returns a Pyramid WSGI application. """
    # create and configure config object
    sessionFactory = UnencryptedCookieSessionFactoryConfig('blueblackbugsblood')
    settings['mako.directories'] = [ 'ufweb:templates' ]
    config = Configurator(settings=settings, session_factory=sessionFactory)
    config.include('pyramid_mako')
 
    # add routes
    config.add_route("crawler", "/crawler")
    config.add_route("backtest", "/backtest")
    config.add_route("backtestResult", "/backtest/result/{name}")
    config.add_route("backtestResult.json", "/backtest/result/{name}/json")
    config.add_route("backtestResults", "/backtest/results")
    config.add_route("backtestResults.json", "/backtest/results/json")
    config.add_route("/", "/")

    # scan packages for views
    config.scan()

    # configure static resource folder
    config.add_static_view('static', 'static', cache_max_age=3600)

    return config.make_wsgi_app()
