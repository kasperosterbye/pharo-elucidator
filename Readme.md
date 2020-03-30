# Elucidator for pharo

> [Elucidate](https://dictionary.cambridge.org/dictionary/english/elucidate)  
> verb [ I or T ]   formal.  
> UK  /iˈluː.sɪ.deɪt/
> US  /iˈluː.sə.deɪt/
 
> to explain something or make something clear:  
> - I don't understand. You'll have to elucidate.  
> - The reasons for the change in weather conditions have been elucidated by several scientists.

The elucidator is a set of tools which will try to explain and clearify classes and packages of Pharo code.

The primary way to get elucidation is the `elucidate` method:

* `aPackage elucidate`
* `aClass elucidate`
* `aBlock elucidate`
* `anObject elucidate`

Each does something slightly different in its attempt to explain the feature.

### Instalation
The elucidator loads using this Metacello script:

```smalltalk
to be done
```

## Eucidations
#### Comments
#### Examples
#### Sequence diagrams
#### Object diagrams

## Design considerations
The design of the elucidator is driven by a few goals and considerations:

1. Documentation written by humans are important, but not the only thing to consider.
2. The architecture should allow for many different kind of elucidations: Documentation, examples, test-examples, diagrams, etc.
3. Each elucidation consists of a information gathering, and a rendering.
4. Each elucidation should provide extensive linking into the code, and easy navigation into the browser or playgrounds.

### Using html for rendering
The elucidator presents its information in a webbrowser. The pharo image is set up as a webserver. This allow the links in the webbrowser to open pharo-tools, and to avoid reinventing a complete rendering mechanism inside pharo.

The individual elucidation tools seperate the information gathering from rendering, but only in methods. It will require a refactoring of the individual elucidations if one want a different rendering.

Having the information rendered in a webbrowser also accomodates for a developing situation with two screens, elucidation in webbrowser, and no overlap to the image.


