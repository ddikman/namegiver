# namegiver
Ruby script to generate random names.

The `namegiver` uses input files from which it randomizes strings and concatenates
to create names. It also outputs to a file with reserved or used names which enables
it to generate unique names in a sequence.

The input files are simply one line per possible string.

## usage
```
ruby give_name.rb -n emotions.txt,pokemons.txt -l -r reserved.txt
```
