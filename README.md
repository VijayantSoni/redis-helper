# redis-helper
Helper for redis operations

**Usage**

1. ```cd \<clone-directory\>```
2. Key count
```
> ./redis-helper.sh --pattern "myPattern*" --action "key-count"

> Key count for pattern "myPattern*" : 5
```
3. Key delete
```
> ./redis-helper.sh --pattern "myPattern*" --action "key-del"

> NOT IMPLEMENTED
```
4. All keys
```
> ./redis-helper.sh --pattern "myPattern*" --action "key-all"

>
KEY NAME 
myPattern1
myPattern2
myPattern3
myPattern4
myPattern5
Total keys found for pattern "myPattern*" : 5
```
5. Longest list type key with size
```
> ./redis-helper.sh --pattern "myListPattern*" --action "key-list-max"

> List-type key for pattern "myListPattern*" with max length is "myListPattern1", having length as 5
```
6. All list type keys with length
```
> ./redis-helper.sh --pattern "myListPattern*" --action "key-list-length"

>
KEY NAME , LENGTH
myListPattern1 , 5
myListPattern2 , 4
myListPattern3 , 1
myListPattern4 , 3
```
