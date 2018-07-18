
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

const swiftMethodNamesToSkip = [
  // The following is skipped since `updateAll` invocation fails with an empty `where` argument
  // and there is no way to provide a working implementation for it.
  'updateAllWithData',
];

// Amend auto-generated method names which don't sound right.
const methodNameReplacementTable = {
  'createWithData': 'createWith',
  'existsWithId': 'existsWith',
  'findByIdWithId': 'findById',
  'findWithSuccess': 'allWithSuccess',
  'updateAllWithWhere': 'updateAllWithWhereFilter',
  'countWithWhere': 'countWithWhereFilter',
};

// Type declaration conversion table for properties.
// To list all the conversion rules in a uniform manner, `<...>` notation is introduced.
const propTypeDefaultConversionTable = {
  'String': '""',
  'Number': '0',
  'Boolean': 'false',
  '<array>': '[Any]()',
  'Array': '[Any]()',
  'ObjectID': '""',
  'Date': 'Date()',
  'object': '[AnyHashable:Any]()',
  'Object': '[AnyHashable:Any]()',
  'ModelConstructor': '[AnyHashable:Any]()',
  'Any': '[AnyHashable:Any]()',
};

const propTypeConversionTable = {
  'String': 'String',
  'Number': 'NSNumber ',
  'Boolean': 'Bool ',
  '<array>': '[Any]',
  'Array': '[Any]',
  'ObjectID': 'String',
  'Date': 'Date',
  'object': '[AnyHashable:Any]',
  'Object': '[AnyHashable:Any]',
  'ModelConstructor': '[AnyHashable:Any]',
  'Any': '[AnyHashable:Any]',
};

const propJsonTypeConversionTable = {
  'String': 'string',
  'Number': 'number ',
  'Boolean': 'bool ',
  '<array>': 'array',
  'Array': 'array',
  'ObjectID': 'string',
  'Date': 'date',
  'object': '',
  'Object': '',
  'ModelConstructor': '',
  'Any': '',
};

// Type conversion table for arguments.
// To list all the conversion rules in a uniform manner, `<...>` notation is introduced.
const argTypeConversionTable = {
  'object data': '<swiftModelType>', // Special case: the argument whose type is `object` and name is `data`.
  'object': '[AnyHashable:Any]',
  'any': 'id',
  'boolean': 'NSNumber',
  'Boolean': 'NSNumber',
  'string': 'String',
  'String': 'String',
  'number': 'NSNumber',
};

// Return type to Obj-C return type conversion table.
const returnTypeConversionTable = {
  'object': 'SwiftyJSON.JSON',
  'number': 'NSNumber',
  'boolean': 'BOOL',
  '<array>': '[SwiftyJSON.JSON]',
  '<void>': 'void',
};

const methodNameConversionTable = {
  'upsertWithWhere': 'upsert(with ',
  'allWithSuccess': 'all(with ',
  'deleteById': 'delete(by ',
  'replaceById': 'replace(by ',
  'findById': 'find(by ',
};

module.exports = {
  methodNamesToSkip: methodNamesToSkip,
  methodNamesUserToKeep: methodNamesUserToKeep,
  swiftMethodNamesToSkip: swiftMethodNamesToSkip,
  methodNameReplacementTable: methodNameReplacementTable,
  propTypeConversionTable: propTypeConversionTable,
  propTypeDefaultConversionTable: propTypeDefaultConversionTable,
  propJsonTypeConversionTable: propJsonTypeConversionTable,
  argTypeConversionTable: argTypeConversionTable,
  returnTypeConversionTable: returnTypeConversionTable,
  methodNameConversionTable: methodNameConversionTable,
};
