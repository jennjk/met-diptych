
###
Workaround to make defining and retrieving angular modules easier and more intuitive.
###
# Courtesy of:  http://www.hiddentao.com/archives/2013/11/04/an-improved-angular-module-split-your-modules-into-multiple-files/
## 


((angular) ->
  origMethod = angular.module
  alreadyRegistered = {}
  
  ###*
  Register/fetch a module.
  
  @param name {string} module name.
  @param reqs {array} list of modules this module depends upon.
  @param configFn {function} config function to run when module loads (only applied for the first call to create this module).
  @returns {*} the created/existing module.
  ###
  angular.module = (name, reqs, configFn) ->
    reqs = reqs or []
    module = null
    if alreadyRegistered[name]
      module = origMethod(name)
      module.requires.push.apply module.requires, reqs
    else
      module = origMethod(name, reqs, configFn)
      alreadyRegistered[name] = module
    module

  return
) angular
##END
