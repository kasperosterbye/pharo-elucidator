# Elucidator for pharo

> [Elucidate](https://dictionary.cambridge.org/dictionary/english/elucidate)  
> verb [ I or T ]   formal.  
> UK  /iˈluː.sɪ.deɪt/
> US  /iˈluː.sə.deɪt/
 
> to explain something or make something clear:  
> - I don't understand. You'll have to elucidate.  
> - The reasons for the change in weather conditions have been elucidated by several scientists.

The elucidator is a set of tools which will try to explain and clarify projects of Pharo code.

The primary way to get elucidation is the `elucidate` method:

* `aClass elucidate`
* `anObject elucidate`
* `'Debugger' elucidate`

The key class to examine is the [<img src="https://avatars1.githubusercontent.com/u/1838382?s=12">](http://localhost:20203/browseClass/Elucidator) `Elucidator` on the class side. For example: [<img src="https://avatars1.githubusercontent.com/u/1838382?s=12">](http://localhost:20203/browseMethod/Elucidator%20class/elucidateObject:range:)`Elucidator>>#elucidateObject:range:`.

### Background
I have had a hard time to understand what the different aspects of the pharo image do. This tool try to gather a lot of information about a given project. There is no pharo concept of a `project`, but this tool defines it as all the packages which shares a common prefix upto the first $-. It works well in practice for me. 

The two above methods finds the project of a class or object, and tries to elucidate that project.

## Instalation
The elucidator loads using this Metacello script:

```smalltalk
Metacello new
   baseline: 'Elucidator';
   repository: 'github://kasperosterbye/pharo-elucidator';
   load.
```

## Eucidations
#### Help
The pharo image has an (rather outdated) build in help system. This section of the elucidation returns those topics for in that help system if any exist.
#### Examples
It is good custom to give examples on the class side of selected classes. But where are those examples? The elucidator finds them for you. 

Some examples are defined by name, others are indicated by pragmas. The elucidator finds both. 
#### Comments
Some packages has comments, some classes has comments. The Elucidator finds all those comments for you. Often you get a good idea of what is going on by skimming over all those comments.

#### Instances
Sometimes it can be useful to start your investigation by looking at classes which actually has instances in the image. The Elucidator finds the 10 classes in the image within a project with the most instances. 

## Design considerations
The design of the elucidator is driven by a few goals and considerations:

1. Documentation written by humans are important, but not the only thing to consider.
2. The architecture should allow for many different kind of elucidations: Documentation, examples, test-examples, diagrams, etc.
3. Each elucidation consists of a information gathering, and a rendering.
4. Each elucidation should provide extensive linking into the code, and easy navigation into the browser or playgrounds.

### Using html for rendering
The elucidator presents its information in a webbrowser. The pharo image is set up as a webserver. This allow the links in the webbrowser to open pharo-tools, and to avoid reinventing a complete rendering mechanism inside pharo.

The individual elucidation tools seperate the information gathering from rendering, but only in methods. It will require a refactoring of the individual elucidations if one want a different rendering.

Having the information rendered in a webbrowser also accomodates for a developer with two screens, elucidation in webbrowser, and no overlap of the image.


