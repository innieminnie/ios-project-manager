# Project Manager API



### Create Todo

[POST] 

/api/todos

```json
{
    "title": "First Todo",
    "description": "This is First Todo",
    "dueDate": "2020-04-03T00:00:00Z"
}
```

**Response**

```json
{
    "id": "48E2E85B-9FC4-4FA7-AE98-D0F2BE71AFF8",
    "title": "First Todo",
    "description": "This is First Todo",
    "dueDate": "2020-04-03T00:00:00Z"
}
```



### Get all Todos

[GET]

/api/todos

**Response**

```json
[
    {
        "id": "598AB2E1-3DD6-4C63-895C-E652AFE3F488",
        "title": "First Todo",
        "description": "This is First Todo",
        "dueDate": "2020-04-03T00:00:00Z"
    },
    {
        "id": "973A04BA-748E-4DB0-96ED-093730212400",
        "title": "Second Todo",
        "description": "This is Second Todo",
        "dueDate": "2021-10-03T00:00:00Z"
    }
]
```



### Get one Todo

[GET]

/api/todos/{todoID}

**Response**

```json
{
    "id": "F6CEEA73-ACFD-4964-B756-8D1211A094F6",
    "title": "Second Todo",
    "description": "This is Second Todo",
    "dueDate": "2021-10-03T00:00:00Z"
}
```



### Update Todo

[PUT]

/api/todos/{todoID}

```json
{
    "title": "Third Todo",
    "description": "Test Third Todo",
    "dueDate": "2021-10-20T00:00:00Z"
}
```

**Response**

```json
{
    "id": "F6D6391F-06A8-4E1C-9B5C-3BF6E11F26B0",
    "title": "Third Todo",
    "description": "Test Third Todo",
    "dueDate": "2021-10-20T00:00:00Z"
}
```





### Delete Todo

[DELETE]

/api/todos/{todoID}

**No Response**

