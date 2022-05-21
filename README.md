# xcode-xlsx
**xcode-xlsx** is a command line tool for importing translations from a **.xlsx** file. Treats files with the extension **.strings** as iOS strings resources and will import translations as simple key/value pairs accordingly.

# Installation
```
git clone https://github.com/obocat/xcode-xlsx.git .
make
make install
```

# Usage
```
usage: xcode-xlsx infile outfile
  infile: XLSX file path.
  outfile: Xcode localization resource path.
```
<p align="center">
  <img width="833" alt="Example" src="https://user-images.githubusercontent.com/1574387/169670793-336cab79-435a-4a8b-884e-22c6232bd778.png">
  <img width="1060" alt="Captura de Pantalla 2022-05-22 a las 0 26 20" src="https://user-images.githubusercontent.com/1574387/169670880-bf3eed2c-8840-4a1b-bd64-a512fe7c4699.png">
</p>

# Requirements

- swift-tools version >= 5.3
- macOS version >= 10.11
