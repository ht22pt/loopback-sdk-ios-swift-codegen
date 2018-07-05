
const methodNamesToSkip = [
  // The followings are pre-implemented in LBPersistedModel.
  // 'create',
  'upsert',
  'deconsteById',
  // The followings are to be supported.
  'createChangeStream',
  'prototype.updateAttributes',
  'prototype.patchAttributes',
];

const methodNamesUserToKeep = [
  // The followings are methods need to create and deconste.
  // 'create'
  'replaceOrCreate',
];

const objcMethodNamesToSkip = [
  // The following is skipped since `updateAll` invocation fails with an empty `where` argument
  // and there is no way to provide a working implementation for it.
  'updateAllWithData',
];

// Amend auto-generated method names which don't sound right.
const methodNameReplacementTable = {
  'findByIdWithId': 'findById',
  'findWithSuccess': 'allWithSuccess',
  'updateAllWithWhere': 'updateAllWithWhereFilter',
  'countWithWhere': 'countWithWhereFilter',
};

// Type declaration conversion table for properties.
// To list all the conversion rules in a uniform manner, `<...>` notation is introduced.
const propTypeConversionTable = {
  'String': 'String',
  'Number': 'NSNumber ',
  'Boolean': 'Bool ',
  '<array>': 'Array',
  'Array': 'Array',
  'ObjectID': 'String',
  'Date': 'Date',
  'object': '[AnyHashable:Any]',
  'Object': '[AnyHashable:Any]',
  'ModelConstructor': '[AnyHashable:Any]',
  'Any': '[AnyHashable:Any]',
};

// Swift to list all the conversion rules in a uniform manner, `<...>` notation is introduced.
const swiftPropTypeConversionTable = {
  'String': 'String',
  'Number': 'NSNumber ',
  'Boolean': 'Bool ',
  '<array>': 'Array',
  'Array': 'Array',
  'ObjectID': 'String',
  'Date': 'Date',
  'object': '[AnyHashable:Any]',
  'Object': '[AnyHashable:Any]',
  'ModelConstructor': '[AnyHashable:Any]',
  'Any': '[AnyHashable:Any]',
};

// Type conversion table for arguments.
// To list all the conversion rules in a uniform manner, `<...>` notation is introduced.
const argTypeConversionTable = {
  'object data': '<objcModelType>', // Special case: the argument whose type is `object` and name is `data`.
  'object': '[AnyHashable:Any]',
  'any': 'id',
  'boolean': 'NSNumber',
  'Boolean': 'NSNumber',
  'string': 'String',
  'String': 'String',
  'number': 'NSNumber',
};

// Swift To list all the conversion rules in a uniform manner, `<...>` notation is introduced.
const swiftArgTypeConversionTable = {
  'object data': '<objcModelType>', // Special case: the argument whose type is `object` and name is `data`.
  'object': 'NSDictionary',
  'any': 'id',
  'boolean': 'NSNumber',
  'Boolean': 'NSNumber',
  'string': 'NSString',
  'String': 'NSString',
  'number': 'NSNumber',
};

// Return type to Obj-C return type conversion table.
const returnTypeConversionTable = {
  'object': 'NSDictionary',
  'number': 'NSNumber',
  'boolean': 'BOOL',
  '<array>': 'NSArray',
  '<void>': 'void',
};

// Return type to Swift return type conversion table.
const swiftReturnTypeConversionTable = {
  'object': 'NSDictionary',
  'number': 'NSNumber',
  'boolean': 'BOOL',
  '<array>': 'NSArray',
  '<void>': 'void',
};

module.exports = {
  methodNamesToSkip: methodNamesToSkip,
  methodNamesUserToKeep: methodNamesUserToKeep,
  objcMethodNamesToSkip: objcMethodNamesToSkip,
  methodNameReplacementTable: methodNameReplacementTable,
  propTypeConversionTable: propTypeConversionTable,
  swiftPropTypeConversionTable: swiftPropTypeConversionTable,
  argTypeConversionTable: argTypeConversionTable,
  swiftArgTypeConversionTable: swiftArgTypeConversionTable,
  returnTypeConversionTable: returnTypeConversionTable,
  swiftReturnTypeConversionTable: swiftReturnTypeConversionTable,
};
