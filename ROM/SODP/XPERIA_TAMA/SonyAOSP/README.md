# SonyAOSP

## Links
- [XDA SonyAOSP](https://xdaforums.com/t/sodp-rom-aosp-sonyaosp-14-alpha.4642894/)

## Requirements
- [Local manifest](https://github.com/sonyxperiadev/local_manifests)

## Instructions
- [SODP instructions](https://developer.sony.com/open-source/aosp-on-xperia-open-devices/guides/aosp-build-instructions/build-aosp-android-14/)

# Containerfile
I provided a dockerfile, to build AOSP without installing all the dependencies on your system.
You can use it like this:
```bash
podman pod rm builder --force && podman kube play builder-pod.yaml
```
