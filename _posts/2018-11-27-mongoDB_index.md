---
layout: post
title:  "MongoDB index 설정"
date:   2018-11-27
categories: MongoDB
author: yogae

---
MongoDB index 종류 및 특징 정리

# index

## 1. Index Properties

 1. TTL index

    -  to create a TTL index on the `lastModifiedDate` field of the `eventlog` collection

      ```js
      db.eventlog.createIndex( { "lastModifiedDate": 1 }, { expireAfterSeconds: 3600 } )
      
      // Expire Documents at a Specific Clock Time
      db.log_events.createIndex( { "expireAt": 1 }, { expireAfterSeconds: 0 } )
      ```

    - If the field is an array, and there are multiple date values in the index, MongoDB uses *lowest* (i.e. earliest) date value in the array to calculate the expiration threshold.

    - If the indexed field in a document is not a [date](https://docs.mongodb.com/manual/reference/glossary/#term-bson-types) or an array that holds a date value(s), the document will not expire.

    - The background task that removes expired documents runs *every 60 seconds*.

    - TTL indexes are a single-field indexes. [Compound indexes](https://docs.mongodb.com/manual/core/index-compound/#index-type-compound) do not support TTL and ignore the`expireAfterSeconds` option.

    - The `_id` field does not support TTL indexes.

 2. Unique Index

    - A unique index ensures that the indexed fields do not store duplicate values

    -  to create a unique index on the `user_id` field of the `members` collection

      ```js
      db.members.createIndex( { "user_id": 1 }, { unique: true } )
      ```

 3. Partial Index

    - Partial indexes only index the documents in a collection that meet a specified filter expression.

    - By indexing a subset of the documents in a collection, partial indexes have lower storage requirements and reduced performance costs for index creation and maintenance.

    - To use the partial index, a query must contain the filter expression

    - The `partialFilterExpression` option accepts a document that specifies the filter condition using:

      - equality expressions (i.e. field: value or using the $eq operator),
      - $exists: true expression,
      - $gt, $gte, $lt, $lte expressions,
      - $type expressions,
      - $and operator at the top-level only

    - the following operation creates a compound index that indexes only the documents with a `rating`field greater than 5.

      ```js
      db.restaurants.createIndex(
         { cuisine: 1 },
         { partialFilterExpression: { rating: { $gt: 5 } } }
      )
      
      db.restaurants.find( { cuisine: "Italian", rating: { $gte: 8 } } )
      
      // not support following query 
      db.restaurants.find( { cuisine: "Italian", rating: { $lt: 8 } } )
      db.restaurants.find( { cuisine: "Italian" } )
      ```

    - Partial Index with Unique Constraint

    - If you specify both the `partialFilterExpression` and a [unique constraint](https://docs.mongodb.com/manual/core/index-unique/#index-type-unique), the unique constraint only applies to the documents that meet the filter expression. A partial index with a unique constraint does not prevent the insertion of documents that do not meet the unique constraint if the documents do not meet the filter criteria.

      ```js
      db.users.createIndex(
         { username: 1 },
         { unique: true, partialFilterExpression: { age: { $gte: 21 } } }
      )
      
      db.users.insert( { username: "david", age: 27 } )
      db.users.insert( { username: "amanda", age: 25 } )
      db.users.insert( { username: "rajiv", age: 32 } )
      
      // not support following queries
      db.users.insert( { username: "david", age: 20 } )
      db.users.insert( { username: "amanda" } )
      db.users.insert( { username: "rajiv", age: null } )
      ```

 4. Case Insensitive Index

    - Case insensitive indexes support queries that perform string comparisons without regard for case.

    - The following example creates a collection with no default collation, then adds an index on the `type` field with a case insensitive collation.

      ```js
      db.createCollection("fruit")
      
      db.fruit.createIndex( { type: 1},
                            { collation: { locale: 'en', strength: 2 } } )
      
      db.fruit.insert( [ { type: "apple" },
                         { type: "Apple" },
                         { type: "APPLE" } ] )
      
      db.fruit.find( { type: "apple" } ) // does not use index, finds one result
      
      db.fruit.find( { type: "apple" } ).collation( { locale: 'en', strength: 2 } )
      // uses the index, finds three results
      
      db.fruit.find( { type: "apple" } ).collation( { locale: 'en', strength: 1 } )
      // does not use the index, finds three results
      
      ```

    - The following example creates a collection called `names` with a default collation, then creates an index on the `first_name` field.

      ```js
      db.createCollection("names", { collation: { locale: 'en_US', strength: 2 } } )
      
      db.names.createIndex( { first_name: 1 } ) // inherits the default collation
      
      db.names.insert( [ { first_name: "Betsy" },
                         { first_name: "BETSY"},
                         { first_name: "betsy"} ] )
      
      db.names.find( { first_name: "betsy" } )
      // inherits the default collation: { collation: { locale: 'en_US', strength: 2 } }
      // finds three results
      
      db.names.find( { first_name: "betsy" } ).collation( { locale: 'en_US' } )
      // does not use the collection's default collation, finds one result
      ```

 5. Sparse Index



## 2. Single Field

- For a single-field index and sort operations, the sort order (i.e. ascending or descending) of the index key does not matter because MongoDB can traverse the index in either direction.

- sample document:

  ```json
  {
    "_id": ObjectId("570c04a4ad233577f97dc459"),
    "score": 1034,
    "location": { state: "NY", city: "New York" }
  }
  ```

- The following operation creates an ascending index on the `score` field

  ```js
  db.records.createIndex( { score: 1 } )
  // a value of 1 specifies an index that orders items in ascending order. A value of -1 specifies an index that orders items in descending order.
  ```

- The created index will support queries that select on the field `score`, such as the following:

  ```js
  db.records.find( { score: 2 } )
  db.records.find( { score: { $gt: 10 } } )
  ```

- Create an Index on Embedded Document

  ```js
  db.records.createIndex( { location: 1 } )
  ```

- The following query can use the index on the `location` field:

  ```js
  db.records.find( { location: { city: "New York", state: "NY" } } )
  ```


## 3. Compound Index

- The order of fields listed in a compound index has significance.

- sample document:

  ```json
  {
   "_id": ObjectId(...),
   "item": "Banana",
   "category": ["food", "produce", "grocery"],
   "location": "4th Street Store",
   "stock": 4,
   "type": "cases"
  }
  ```

- The following operation creates an ascending index on the `item` and `stock` fields:

  ```js
  db.products.createIndex( { "item": 1, "stock": 1 } )
  ```

- The order of the fields listed in a compound index is important. The index will contain references to documents sorted first by the values of the `item` field and, within each value of the `item` field, sorted by values of the stock field.

- the index supports queries on the `item` field as well as both `item`and `stock` fields:

  ```js
  db.products.find( { item: "Banana" } )
  db.products.find( { item: "Banana", stock: { $gt: 5 } } )
  
  // not support following query 
  db.products.find( { item: "Banana", stock: { $gt: 5 } } )
  ```

- for compound indexes, sort order can matter in determining whether the index can support a sort operation.

  ```js
  db.events.createIndex( { "username" : 1, "date" : -1 } )
  db.events.find().sort( { username: 1, date: -1 } )
  db.events.find().sort( { username: -1, date: 1 } )
  
  // not support following query
  db.events.find().sort( { username: 1, date: 1 } )
  ```

- Prefixes

  ```js
  db.products.createIndex({ "item": 1, "location": 1, "stock": 1 })
  db.products.find( { item: "Banana" } )
  db.products.find( { item: "Banana", location: "4th Street Store" } )
  db.products.find( { item: "Banana", location: "4th Street Store", stock: { $gt: 5 } } )
  
  // not support following queries
  db.products.find( { stock: { $gt: 5 } } )
  db.products.find( { location: "4th Street Store" } )
  db.products.find( { item: "Banana", stock: { $gt: 5 } } )
  ```


## 4. Multikey Index

- MongoDB uses [multikey indexes](https://docs.mongodb.com/manual/core/index-multikey/) to index the content stored in arrays

- MongoDB automatically creates a multikey index if any indexed field is an array; you do not need to explicitly specify the multikey type.

- Limitations

  - You cannot create a compound multikey index if more than one to-be-indexed field of a document is an array.

    ```json
    { _id: 1, a: [ 1, 2 ], b: [ 1, 2 ], category: "AB - both arrays" }
    // You cannot create a compound multikey index { a: 1, b: 1 } on the collection since both the a and b fields are arrays.
    ```

- If a field is an array of documents, you can index the embedded fields to create a compound index.

  ```json
  { _id: 1, a: [ { x: 5, z: [ 1, 2 ] }, { z: [ 1, 2 ] } ] }
  { _id: 2, a: [ { x: 5 }, { z: 4 } ] }
  // You can create a compound index on { "a.x": 1, "a.z": 1 }.
  ```

- Query on the Array Field as a Whole

  - consider an `inventory` collection that contains the following documents:

    ```json
    { _id: 5, type: "food", item: "aaa", ratings: [ 5, 8, 9 ] }
    { _id: 6, type: "food", item: "bbb", ratings: [ 5, 9 ] }
    { _id: 7, type: "food", item: "ccc", ratings: [ 9, 5, 8 ] }
    { _id: 8, type: "food", item: "ddd", ratings: [ 9, 5 ] }
    { _id: 9, type: "food", item: "eee", ratings: [ 5, 9, 5 ] }
    ```

  - The collection has a multikey index on the `ratings` field:

    ```js
    db.inventory.createIndex( { ratings: 1 } )
    ```

  - The following query looks for documents where the `ratings` field is the array `[ 5, 9 ]`:

    ```js
    db.inventory.find( { ratings: [ 5, 9 ] } )
    ```

- Index Arrays with Embedded Documents

  - Consider an `inventory` collection with documents of the following form:

    ```json
    {
      _id: 1,
      item: "abc",
      stock: [
        { size: "S", color: "red", quantity: 25 },
        { size: "S", color: "blue", quantity: 10 },
        { size: "M", color: "blue", quantity: 50 }
      ]
    }
    {
      _id: 2,
      item: "def",
      stock: [
        { size: "S", color: "blue", quantity: 20 },
        { size: "M", color: "blue", quantity: 5 },
        { size: "M", color: "black", quantity: 10 },
        { size: "L", color: "red", quantity: 2 }
      ]
    }
    ```

  - The following operation creates a multikey index on the `stock.size` and `stock.quantity` fields:

    ```js
    db.inventory.createIndex( { "stock.size": 1, "stock.quantity": 1 } )
    ```

  - The compound multikey index can support queries with predicates that include both indexed fields as well as predicates that include only the index prefix `"stock.size"`

    ```js
    db.inventory.find( { "stock.size": "M" } )
    db.inventory.find( { "stock.size": "S", "stock.quantity": { $gt: 20 } } )
    ```

## 5. Text Index

- A collection can have at most **one** `text` index.

- To index a field that contains a string or an array of string elements, include the field and specify the string literal `"text"` in the index document, as in the following example:

  ```js
  db.reviews.createIndex( { comments: "text" } )
  // You can index multiple fields for the text index.
  db.reviews.createIndex(
     {
       subject: "text",
       comments: "text"
     }
   )
  // MongoDB indexes every field that contains string data for each document in the collection.
  db.collection.createIndex( { "$**": "text" } )
  ```
