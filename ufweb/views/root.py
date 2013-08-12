'''
Created on July 1, 2012

@author: ppa
'''
from pyramid.view import view_config

import logging
LOG = logging.getLogger(__name__)

class Root:
    ''' root views '''

    def __init__(self, request):
        ''' constructor '''
        self.request = request
        self.params = request.params
        self.session = request.session
        self.settings = request.registry.settings

    def init(self):
        ''' post wire initialization '''
        pass

    ###############################################################################
    # controller functions
    @view_config(route_name='/', renderer='ufweb:templates/root/getRoot.mako')
    def getRootHtml(self):
        ''' get root html '''
        return {}
