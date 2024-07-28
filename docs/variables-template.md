# Variables template

The variables template defines variables that are used for each pipeline we define.  
We use a template file to centralize the changes.

The template in inserted on top of each pipeline file.

```yaml
variables:
  - template: templates/azure-pipelines-variables.yml
```

The main variable is the versioning of the product.  
The build stage contains a [step](./build-template.md#calculate-build-number) where we calculate and set the [semantic version](https://semver.org) of the application.

**versionPrefix**  
Set the semantic version prefix (major.minor.patch) for the application.  
This usually corresponds to the version you're currently developing.  
When developing a new version, you only need to modify this number.

```yaml
  versionPrefix: '1.1.0'
```

**build**  
I used the [counter expression](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/expressions?view=azure-devops#counter) to generate an incremental build number for each build triggered by this pipeline.  
The counter is linked to the version *versionPrefix* value. When this value changes (version increment), a new counter is started from 1.  

```yaml
  build: $[counter(variables['versionPrefix'], 1)]
```

**version**  
This variable combines the previous *versionPrefix* with the calculated *build* into a 4-digit version number.

```yaml
  version: $(versionPrefix).$(build)
```

**isPR**  
This variable is used to identify easily if the pipeline was triggered through a Pull Request or not.  
If so, we skip certain steps such as publish artifacts.

```yaml
  isPR: $[eq(variables['Build.Reason'], 'PullRequest')]
```

**disable.coverage.autogenerate**  
This variable is set because it interferes with our coverage report generator.  
https://github.com/danielpalme/ReportGenerator/wiki/Integration#attention

```yaml
  disable.coverage.autogenerate: 'true'
```