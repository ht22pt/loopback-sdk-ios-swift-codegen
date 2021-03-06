// Copyright © 2018 Arrive Technologies. All rights reserved.
// Node module: loopback-sdk-ios-swift-codegen
// This file is licensed under the MIT License.
// License text available at https://opensource.org/licenses/MIT

const fs = require('fs');
const ejs = require('ejs');
const moment = require('moment');
const pascalCase = require('pascal-case');
const path = require('path');

const logger = require('./logger');

const {
  methodNamesToSkip,
  methodNamesUserToKeep,
  swiftMethodNamesToSkip,
  methodNameReplacementTable,
  propTypeConversionTable,
  propTypeDefaultConversionTable,
  propJsonTypeConversionTable,
  argTypeConversionTable,
  returnTypeConversionTable,
  methodNameConversionTable,
} = require('./data-type-conversion');

const baseModels = ['Application', 'User', 'Notification', 'Installation', 'Push'];
const skipRelation = ['AccessToken'];
const modelsName = [];

const executePropeties = ['id'];
const executeMethods = {};
const includeMethods = {};
let enableInclude = false;
let enableExecute = false;

const SCOPE_METHOD_REGEX = /^prototype.__([^_]+)__(.+)$/;

/**
 * Generate iOS Client-side Swift representation of the models.
 *
 * @param {Object} app The loopback application created via `app = loopback()`.
 * @returns {Object} A hash map indexed by file names with file contents as the value.
 */
exports.swiftModels = function generateServices (
  app,
  appName,
  modelPrefix,
  modelPostfix,
  includeMethodPath = null,
  executeMethodPath = null,
  verbose = false
) {
  // Start processing here
  processingIncludeMethod(includeMethodPath);
  processingExecuteMethod(executeMethodPath);
  const models = describeModels(app);

  // Support relation
  Object.keys(models).forEach(function (modelName) {
    modelsName.push(models[modelName].name);
    const relations = [];
    Object.keys(models[modelName].relations).forEach(function (relationName) {
      const relationModel = models[modelName].relations[relationName].model;
      if (skipRelation.indexOf(relationModel) === -1 &&
          relationModel !== models[modelName].name &&
          relations.indexOf(relationModel) === -1) {
        relations.push(pascalCase(relationModel));
      }
    });
    models[modelName].relationModel = relations;
  });

  // Processing data for models to support generate
  addSwiftNames(models, modelPrefix, modelPostfix, verbose);

  const swiftStructTemplate = readTemplate('./swift-model.ejs');
  const swiftRepoTemplate = readTemplate('./swift-repo.ejs');

  const ret = {};

  for (let modelName in models) {
    let modelDesc = models[modelName];
    modelDesc.prefix = modelPrefix;
    modelDesc.postfix = modelPostfix;
    modelDesc.appName = appName;
    modelDesc.date = moment().format('DD/MM/YYYY');
    modelDesc.year = moment().format('YYYY');
    let swiftModelName = models[modelName].swiftModelName;

    let script = renderContent(swiftStructTemplate, modelDesc);
    ret[modelPrefix + swiftModelName + modelPostfix + '.swift'] = script;

    // Skip repository without any methods
    if (Array.isArray(modelDesc.methods) && modelDesc.methods.length > 0) {
      script = renderContent(swiftRepoTemplate, modelDesc);
      ret[modelPrefix + swiftModelName + 'Repository.swift'] = script;
    }
  }

  return ret;
};

function describeModels (app) {
  const result = {};

  // Get special RestClass
  let listRestClass = app.handler('rest').adapter.getClasses();
  let userRestApis = [];
  for (let i = 0; i < listRestClass.length; i++) {
    if (listRestClass[i].name === 'User') {
      // TODO: Need some check in default model
      for (let j = 0; j < listRestClass[i].methods.length; j++) {
        userRestApis[userRestApis.length] = listRestClass[i].methods[j].name;
      }
      break;
    }
  }

  app.handler('rest').adapter.getClasses().forEach(function (c) {
    let name = c.name;
    let modelDefinition = app.models[name].definition;

    if (!c.ctor) {
      // Skip classes that don't have a shared ctor
      // as they are not LoopBack models
      logger.error('Skipping %j as it is not a LoopBack model', name);
      return;
    }

    // Skip the User class as its Obj-C implementation is provided as a part of the SDK framework.
    let isUser = c.name === 'User';

    // let isUser = c.sharedClass.ctor.prototype instanceof app.loopback.User ||
    // c.sharedClass.ctor.prototype === app.loopback.User.prototype;
    if (isUser) {
      return;
    }

    c.pluralName = c.sharedClass.ctor.pluralModelName;
    c.props = modelDefinition.properties;
    c.baseModel = modelDefinition.settings.base;
    if (c.baseModel != null && typeof (c.baseModel) === 'function') {
      c.baseModel = '';
    }
    if (modelDefinition._ids != null) {
      c.isGenerated = modelDefinition._ids[0].property.generated;
    } else {
      c.isGenerated = false;
    }
    c.relations = modelDefinition.settings.relations;
    // TODO: Add relation or verify here ?
    c.acls = modelDefinition.settings.acls;
    c.validations = modelDefinition.settings.validations;

    let isBaseUser = c.sharedClass.ctor.prototype instanceof app.loopback.User ||
      c.sharedClass.ctor.prototype === app.loopback.User.prototype;

    if (isBaseUser) {
      for (let i = 0; i < c.methods.length; i++) {
        if (userRestApis.indexOf(c.methods[i].name) !== -1 && methodNamesUserToKeep.indexOf(c.methods[i].name) !== -1) {
          // Remove
          c.methods.splice(i, 1);
          i--;
        }
      }
    }

    const modelName = c.name;
    const modelIncludeMethods = includeMethods[modelName];
    const modelExecuteMethods = executeMethods[modelName];

    for (let i = c.methods.length - 1; i >= 0; i -= 1) {
      // Check include first
      if (enableInclude &&
        Array.isArray(modelIncludeMethods) &&
        modelIncludeMethods.indexOf(c.methods[i].fullName) === -1) {
        c.methods.splice(i, 1);
        continue;
      }
      // Next check execute
      if (enableExecute &&
        Array.isArray(modelExecuteMethods) &&
        modelExecuteMethods.indexOf(c.methods[i].fullName) !== -1) {
        c.methods.splice(i, 1);
        continue;
      }

      let ctor = c.methods[i].restClass.ctor;
      if (!ctor || c.methods[i].sharedMethod.isStatic) continue;
      c.methods[i].accepts = ctor.accepts.concat(c.methods[i].accepts);
    }

    result[name] = c;
  });

  buildScopes(result);

  return result;
}

function buildScopes (models) {
  for (let modelName in models) {
    buildScopesOfModel(models, modelName);
  }
}

function buildScopesOfModel (models, modelName) {
  let modelClass = models[modelName];

  modelClass.scopes = {};
  modelClass.methods.forEach(function (method) {
    buildScopeMethod(models, modelName, method);
  });

  return modelClass;
}

// reverse-engineer scope method
// defined by loopback-datasource-juggler/utility/scope.js
function buildScopeMethod (models, modelName, method) {
  let modelClass = models[modelName];
  let match = method.name.match(SCOPE_METHOD_REGEX);
  if (!match) return;

  let op = match[1];
  let scopeName = match[2];
  let modelPrototype = modelClass.sharedClass.ctor.prototype;
  let targetClass = modelPrototype[scopeName]._targetClass;

  // Check rename method in special case
  if (match[0].indexOf('prototype.') !== -1) {
    method.name = op + '__' + scopeName;
  }

  if (modelClass.scopes[scopeName] === undefined) {
    if (!targetClass) {
      logger.error(
        'Warning: scope %s.%s is missing _targetClass property.' +
        '\nThe iOS code for this scope won\'t be generated.' +
        '\nPlease upgrade to the latest version of' +
        '\nloopback-datasource-juggler to fix the problem.',
        modelName, scopeName
      );
      modelClass.scopes[scopeName] = null;
      return;
    }

    if (!findModelByName(models, targetClass)) {
      logger.error(
        'Warning: scope %s.%s targets class %j, which is not exposed ' +
        '\nvia remoting. The iOS code for this scope won\'t be generated.',
        modelName, scopeName, targetClass
      );
      modelClass.scopes[scopeName] = null;
      return;
    }

    modelClass.scopes[scopeName] = {
      methods: {},
      targetClass: targetClass,
    };
  } else if (modelClass.scopes[scopeName] === null) {
    // Skip the scope, the warning was already reported
    return;
  }

  let apiName = scopeName;
  if (op === 'get') {
    // no-op, create the scope accessor
  } else if (op === 'delete') {
    apiName += '.destroyAll';
  } else {
    apiName += '.' + op;
  }

  let scopeMethod = Object.create(method);
  /* Remove reverseName, it's always undefined and somethings error */
  scopeMethod.name = scopeName;
  // scopeMethod.name = reverseName;
  // override possibly inherited values
  scopeMethod.deprecated = false;
  scopeMethod.internal = false;
  modelClass.scopes[scopeName].methods[apiName] = scopeMethod;
  if (scopeMethod.name.match(/create/)) {
    let scopeCreateMany = Object.create(scopeMethod);
    scopeCreateMany.name = scopeCreateMany.name.replace(
      /create/,
      'createMany'
    );
    scopeCreateMany.isReturningArray = function () {
      return true;
    };
    apiName = apiName.replace(/create/, 'createMany');
    modelClass.scopes[scopeName].methods[apiName] = scopeCreateMany;
  }
}

function findModelByName (models, name) {
  for (let n in models) {
    if (n.toLowerCase() === name.toLowerCase()) {
      return models[n];
    }
  }
}

function addSwiftNames (models, modelPrefix, modelPostfix, verbose) {
  for (let modelName in models) {
    if (verbose) {
      logger.error('\nProcessing model:' + modelName + '...');
    }
    let meta = models[modelName];
    meta.swiftModelName = pascalCase(modelName);
    meta.swiftRepoName = pascalCase(modelName) + 'Repository';
    if (meta.baseModel === 'Model' || meta.baseModel === 'PersistedModel' ||
      baseModels.indexOf(meta.baseModel) !== -1) {
      meta.swiftBaseModel = 'LB' + meta.baseModel;
    } else {
      throw new Error('Unknown base model: ' + meta.baseModel + ' for model: ' + modelName + '');
    }
    meta.swiftProps = [];
    for (let propName in meta.props) {
      if (executePropeties.indexOf(propName) !== -1) {
        // `_id` is already defined in LBPersistedModel
        continue;
      }
      let prop = meta.props[propName];
      if (verbose) {
        logger.error(' Property:' + propName + '', prop);
      }
      let swiftProp = convertToSwiftPropType(prop.type);
      let swiftDefaultProp = convertToSwiftDefaultPropType(prop.type);
      let swiftJsonProp = convertToSwiftJsonPropType(prop.type);
      if (typeof swiftProp === 'undefined') {
        throw new Error('Unsupported property type: ' + prop.type.name + ' in model: ' + modelName + '');
      }
      meta.swiftProps.push({
        name: propName,
        type: swiftProp,
        typeJson: swiftJsonProp,
        defaultType: swiftDefaultProp,
      });
    }

    meta.swiftMethods = [];
    meta.methods.forEach(function (method) {
      if (verbose) {
        logger.error(`Method: ${method.name}`, method);
      }
      addSwiftMethodInfo(meta, method, modelName, modelPrefix, modelPostfix, true);
      if (hasOptionalArguments(method)) {
        addSwiftMethodInfo(meta, method, modelName, modelPrefix, modelPostfix, false);
      }
    });
  }
}

function addSwiftMethodInfo (meta, method, modelName, prefix, postfix, skipOptionalArguments) {
  if (methodNamesToSkip.indexOf(method.name) >= 0) {
    return;
  }

  // Skip some methods from model User
  let methodPrototype = '';
  let methodName = method.name;
  methodName = methodName.replace('prototype.', '');
  let paramAssignments;
  let bodyParamAssignments;
  method.accepts.forEach(function (param) {
    const paramRequired = param.required || (param.http && param.http.source === 'body');
    if (!paramRequired && skipOptionalArguments) {
      return;
    }

    if (param.arg === 'options') {
      return;
    }

    let swiftModelType = meta.swiftModelName;
    if (typeof (param.model) === 'string') {
      swiftModelType = param.model;
    }
    let argType = convertToSwiftArgType(param.type, param.arg, swiftModelType, prefix, postfix);
    if (typeof argType === 'undefined') {
      throw new Error('Unsupported argument type: ' + param.type + ' in model: ' + modelName + '');
    }
    let argName = (param.arg === 'id') ? 'id' : param.arg;
    if (argName === 'where') {
      // MARK: Workaround for swift language with keyword "where"
      argName = 'filterWhere';
    }
    let argRightValue = argName;
    if (argType === swiftModelType) {
      argRightValue = param.arg + '.toDictionary()';
    } else if (argType === 'NSDictionary') {
      argRightValue = param.arg;
    }
    // TODO: Update structure method name here
    if (methodName === method.name) {
      methodName = convertMethodNameToSwiftMethodBlockType(methodName);
    } else {
      // methodPrototype += ' ' + param.arg;
    }

    if (param.http && param.http.source === 'body') {
      if (bodyParamAssignments) {
        throw new Error('Multiple body arguments specified in method: ' + method.name + ' of model: ' + modelName + '');
      }
      bodyParamAssignments = argRightValue;
    } else {
      if (!paramAssignments) {
        paramAssignments = `"${param.arg}": ${argRightValue}`;
      } else {
        paramAssignments += `, "${param.arg}": ${argRightValue}`;
      }
    }

    if (methodPrototype === '') {
      methodPrototype += `${argName}:${argType}`;
    } else {
      methodPrototype += `, ${argName}:${argType}`;
    }
  });

  const returnArg = method.returns[0] && method.returns[0].arg;
  const returnType = method.returns[0] && method.returns[0].type;
  const swiftReturnType = convertToSwiftReturnType(returnType, modelName, meta.swiftModelName, prefix, postfix);
  if (typeof swiftReturnType === 'undefined') {
    throw new Error(`Unsupported return type: ${returnType} in method: ${method.name} of model: ${modelName}`);
  }
  const successBlockType = convertToSwiftSuccessBlockType(swiftReturnType);

  if (methodName === method.name) {
    methodName = convertMethodNameToSwiftMethodBlockType(methodName);
    methodPrototype += `success: @escaping (${successBlockType}) -> Void`;
  } else {
    methodPrototype += `\n    ,success: @escaping (${successBlockType}) -> Void`;
  }
  methodPrototype += '\n    ,failure: @escaping ALFailureBlock)';

  if (swiftMethodNamesToSkip.indexOf(methodName) >= 0) {
    return;
  }
  if (methodNameReplacementTable[methodName]) {
    methodName = methodNameReplacementTable[methodName];
  }
  methodPrototype = methodName + methodPrototype;
  let newTypeReturn = '';
  if (Array.isArray(returnType)) {
    newTypeReturn = returnType[0];
  }

  meta.swiftMethods.push({
    rawName: method.name,
    prototype: methodPrototype,
    returnArg: returnArg,
    swiftReturnType: swiftReturnType,
    originOSwiftReturnType: newTypeReturn,
    paramAssignments: typeof paramAssignments !== 'string' ? ':' : paramAssignments,
    bodyParamAssignments: bodyParamAssignments,
  });
  method.swiftGenerated = true;
}

/*
function duplicateMethod (methods, checkMethod) {
  for (let method in methods) {
    checkMethod
  }
  return false;
}
*/

function hasOptionalArguments (method) {
  for (let idx in method.accepts) {
    let param = method.accepts[idx];
    if (param.arg !== 'options') {
      let paramRequired = param.required || (param.http && param.http.source === 'body');
      if (!paramRequired) {
        return true;
      }
    }
  }
  return false;
}

function readTemplate (filename) {
  let ret = fs.readFileSync(
    require.resolve(filename), {
      encoding: 'utf-8',
    }
  );
  return ret;
}

function renderContent (template, modelMetaInfo) {
  let script = ejs.render(
    template, {
      meta: modelMetaInfo,
    }
  );
  return script;
}

// === Support convert data

function convertToSwiftPropType (type) {
  if (Array.isArray(type)) {
    return propTypeConversionTable['<array>'];
  }
  return propTypeConversionTable[type.name];
}

function convertToSwiftDefaultPropType (type) {
  if (Array.isArray(type)) {
    return propTypeDefaultConversionTable['<array>'];
  }
  return propTypeDefaultConversionTable[type.name];
}

function convertToSwiftJsonPropType (type) {
  if (Array.isArray(type)) {
    return propJsonTypeConversionTable['<array>'];
  }
  return propJsonTypeConversionTable[type.name];
}

function convertToSwiftArgType (type, name, swiftModelType, modelPrefix, modelPostfix) {
  let swiftType = argTypeConversionTable[type + ' ' + name];
  swiftType = swiftType || argTypeConversionTable[type];
  if (swiftType) {
    if (swiftType === '<swiftModelType>') {
      swiftType = modelPrefix + swiftType.replace('<swiftModelType>', swiftModelType) + modelPostfix;
    }
  }
  return swiftType;
}

function convertToSwiftReturnType (type, modelName, swiftModelName, modelPrefix, modelPostfix) {
  if (type === modelName) {
    return modelPrefix + swiftModelName + modelPostfix;
  }

  /* In case not found any type,
   * it maybe is object type from other model, must return type name
   */
  if (modelsName.indexOf(type) !== -1) {
    return modelPrefix + pascalCase(type) + modelPostfix;
  }

  if (typeof type === 'undefined') {
    type = '<void>';
  }
  if (Array.isArray(type)) {
    type = '<array>';
  }

  // Workaround for run ok
  if (typeof type === 'object') {
    type = 'number';
  }
  return returnTypeConversionTable[type];
}

function convertToSwiftSuccessBlockType (swiftType) {
  let returnArgType;
  if (swiftType === 'void') {
    returnArgType = '';
  } else if (swiftType === 'BOOL') { // primitive type
    returnArgType = swiftType;
  } else {
    returnArgType = swiftType;
  }
  return returnArgType;
}

function convertMethodNameToSwiftMethodBlockType (methodName) {
  const convertName = methodNameConversionTable[methodName];
  if (typeof convertName !== 'string') {
    return (methodName += '(with ');
  }
  return convertName;
}

function processingIncludeMethod (includePath) {
  // Read folder
  if (!fs.existsSync(includePath)) {
    return null;
  }

  const listFiles = fs.readdirSync(includePath);

  listFiles.forEach(function (file) {
    // Get file name
    const fileName = path.basename(file, '.json');
    try {
      const jsonInclude = JSON.parse(fs.readFileSync(`${includePath}/${file}`));
      if (!Array.isArray(jsonInclude.include) || jsonInclude.include.length === 0) {
        // Nothing to do
        return;
      }
      const modelName = typeof jsonInclude.name === 'string' ? jsonInclude.name : fileName;
      const includeMethod = [];
      jsonInclude.include.forEach(function (includeName) {
        includeMethod.push(`${modelName}.${includeName}`);
      });

      if (includeMethod.length > 0) {
        includeMethods[modelName] = includeMethod;
        if (!enableInclude) {
          enableInclude = true;
        }
      }
    } catch (err) {
      logger.error(err);
    }
  });
}

function processingExecuteMethod (executePath) {
  // Read folder
  if (!fs.existsSync(executePath)) {
    return null;
  }

  const listFiles = fs.readdirSync(executePath);

  listFiles.forEach(function (file) {
    // Get file name
    const fileName = path.basename(file, '.json');
    try {
      const jsonExecute = JSON.parse(fs.readFileSync(`${executePath}/${file}`));
      if (!Array.isArray(jsonExecute.execute) || jsonExecute.execute.length === 0) {
        // Nothing to do
        return;
      }

      const modelName = typeof jsonExecute.name === 'string' ? jsonExecute.name : fileName;
      const executeMethod = [];
      const includeMethod = includeMethods[modelName] ? includeMethods[modelName] : [];
      jsonExecute.execute.forEach(function (executeName) {
        if (includeMethod.indexOf(`${modelName}.${executeName}`) === -1) {
          executeMethod.push(`${modelName}.${executeName}`);
        }
      });

      if (executeMethod.length > 0) {
        executeMethods[modelName] = executeMethod;
        if (!enableExecute) {
          enableExecute = true;
        }
      }
    } catch (err) {
      logger.error(err);
    }
  });
}
