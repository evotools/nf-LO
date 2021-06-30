# Configurations

If you have the need to run *nf-LO* in a custom cluster or computing environment, then you need to generate a custom nextflow configuration file.
We tried to implement the configuration files from [nf-core/configs](https://github.com/nf-core/configs). In case of bugs raising from these configurations, let us know and we'll try to fix them as soon as possible.

If your institute doesn't figure in the above list, or the built-in profiles are not working for you, you then need to prepare a new configuration file. The preparation is explained in detail in the [nextflow documentation](https://www.nextflow.io/docs/latest/config.html). You can then load the custom profile by using the `--custom_profile myprofile.conf`

If you need to further customize the workflow for your needs, you can clone the repository locally and run it after changing the workflow to fit your needs.
To do so, git clone the repository:
```
git clone https://github.com/evotools/nf-LO.git
```

After you edited the `nextflow.config` file to make it suited to your computation environment, you can test it locally by pointing to the `main.nf` file in the nf-LO folder:
```
nextflow run ./nf-LO/main.nf -profile test,docker
```

In case you need help in preparing the configuration files for you system, let us know in the issues and we will try to help!