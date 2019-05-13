
# tomate

My own [Pomodoro](https://francescocirillo.com/pages/pomodoro-technique) timer and logger.

## usage

### start

Start a pomodoro about writing documentation:
```
$ tomate start write documentation
```

### query

Query, is there a pomodoro currently going on?
```
$ tomate
```
which answers
```
no pomodoro currently
```
or
```
current pomodoro ends in 24m at 2019-05-13 11:12:00 +0900
> 2019-05-13 10:47 -   :    write documentation
```

### kill

Kills the current pomodoro
```
$ tomate kill
```
yields something like
```
current pomodoro (65301) should end in 24m at 2019-05-13 14:09:00 +0900
killed.
```


## license

MIT, see [LICENSE.txt](LICENSE.txt)

