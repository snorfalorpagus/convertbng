[![Travis (.org)](https://img.shields.io/travis/:urschrei/:convertbng.svg)](https://travis-ci.org/urschrei/convertbng)
[![Windows Build Status](https://ci.appveyor.com/api/projects/status/t9icsmbsut93k7pg?branch=master&svg=true)](https://ci.appveyor.com/project/urschrei/convertbng) [![Coverage Status](https://coveralls.io/repos/github/urschrei/convertbng/badge.svg?branch=master)](https://coveralls.io/github/urschrei/convertbng?branch=master) [![PyPI Version](https://img.shields.io/pypi/v/convertbng.svg)](https://pypi.python.org/pypi/convertbng) [![MIT licensed](https://img.shields.io/badge/license-MIT-blue.svg)](license.txt)

# Description
A utility library for converting decimal [WGS84](http://spatialreference.org/ref/epsg/wgs-84/) longitude and latitude coordinates into ETRS89 ([EPSG:25830](http://spatialreference.org/ref/epsg/etrs89-utm-zone-30n/)) and/or British National Grid (More correctly: OSGB36, or [EPSG:27700](http://spatialreference.org/ref/epsg/osgb-1936-british-national-grid/)) Eastings and Northings, and vice versa.  

Conversion is handled by a [Rust binary](https://github.com/urschrei/rust_bng) using FFI, and is quite fast. Some benchmarks can be found [here](https://github.com/urschrei/lonlat_bng#benchmark).

# Installation
`pip install convertbng`  
Please use an up-to-date version of pip (`8.1.2` as of June 2016)

## Supported Platforms
The package has been built for and tested on the following platforms:
- Linux 64-bit, Python 2.7 and 3.6, as a [manylinux1](https://www.python.org/dev/peps/pep-0513) wheel
- OS X 64-bit, Python 2.7, 3.6 and 3.7, as a wheel for versions 10.6 and above
- Windows 32-bit and 64-bit Python 2.7 and 32-bit Python 3.4, as a wheel.

### Windows Binaries
The Rust DLL and the Cython extension used by this package have been built with an MSVC toolchain. You shouldn't need to install any additional runtimes in order for the wheel to work, but please open an issue if you encounter any errors.

# Usage
The functions accept either a sequence (such as a list or numpy array) of longitude or easting values and a sequence of latitude or northing values, **or** a single longitude/easting value and single latitude/northing value. Note the return type:  
`"returns a list of two lists containing floats, respectively"`

**NOTE**: Coordinate pairs outside the BNG bounding box, or without OSTN15 coverage will return a result of  
`[[nan], [nan]]`, which cannot be mapped. Since transformed coordinates are guaranteed to be returned in the same order as the input, it is trivial to check for this value. Alternatively, ensure your data fall within the bounding box before transforming them:  

**Longitude**:  
East: 1.7800  
West: -7.5600  
**Latitude**:  
North: 60.8400  
South: 49.9600  

All functions try to be liberal about what containers they accept: `list`, `tuple`, `array.array`, `numpy.ndarray`, and pretty much anything that has the `__iter__` attribute should work, including generators.

```python
from convertbng.util import convert_bng, convert_lonlat

# convert a single value
res = convert_bng(lon, lat)

# convert lists of longitude and latitude values to OSGB36 Eastings and Northings, using OSTN15 corrections
lons = [lon1, lon2, lon3]
lats = [lat1, lat2, lat3]
res_list = convert_bng(lons, lats)

# convert lists of BNG Eastings and Northings to longitude, latitude
eastings = [easting1, easting2, easting3]
northings = [northing1, northing2, northing3]
res_list_en = convert_lonlat(eastings, northings)

# assumes numpy imported as np
lons_np = np.array(lons)
lats_np = np.array(lats)
    res_list_np = convert_bng(lons_np, lats_np)
```

## But I Have a List of Coordinate Pairs
    coords = [[1.0, 2.0], [3.0, 4.0]]
    a, b = list(zip(*coords))
    # a is (1.0, 3.0)
    # b is (2.0, 4.0)

### But I have `Shapely` Geometries
    from shapely.geometry import LineString

    ls = LineString([[651307.003, 313255.686], [651307.004, 313255.687]])
    new_linestring = LineString(
        zip(*convert_etrs89_to_lonlat(*zip(*ls.coords)))
    )

# Experimental Cython Module
If you're comfortable with restricting yourself to `NumPy f64` arrays, you may use the Cython functions instead. These are identical to those listed below, and are selected by changing the import statement  
`from convertbng.util import` to  
**`from convertbng.cutil import`**  

The conversion functions will accept most sequences which implement `__iter__`, as above (`list`, `tuple`, `float`, `array.array`, `numpy.ndarray`), but **will always return `NumPy f64 ndarray`**. In addition, you must ensure that your inputs are `float`, `f64`, or `d` in the case of `array.array`.  



# Available Conversions (AKA I Want To…)
- transform longitudes and latitudes to OSGB36 Eastings and Northings **very accurately**:
    - use `convert_bng()`
- transform OSGB36 Eastings and Northings to longitude and latitude, **very accurately**:
    - use `convert_lonlat()`
- transform longitudes and latitudes to ETRS89 Eastings and Northings, **very quickly** (without OSTN15 corrections):
    - use `convert_to_etrs89()`
- transform ETRS89 Eastings and Northings to ETRS89 longitude and latitude, **very quickly** (the transformation does not use OSTN15):
    - use `convert_etrs89_to_lonlat()`
- convert ETRS89 Eastings and Northings to their most accurate real-world representation, using the OSTN15 corrections:
    - use `convert_etrs89_to_osgb36()`

Provided for completeness:

- transform accurate OSGB36 Eastings and Northings to *less-accurate* ETRS89 Eastings and Northings:
    - use `convert_osgb36_to_etrs89()`

# Relationship between ETRS89 and WGS84
From [Transformations and OSGM02™ User guide](https://www.ordnancesurvey.co.uk/business-and-government/help-and-support/navigation-technology/os-net/formats-for-developers.html), p7. Emphasis mine.
>[…] ETRS89 is a precise version of the better known WGS84 reference system optimised for use in Europe; **however, for most purposes it can be considered equivalent to WGS84**.
Specifically, the motion of the European continental plate is not apparent in ETRS89, which allows a fixed relationship to be established between this system and Ordnance Survey mapping coordinate systems.
Additional precise versions of WGS84 are currently in use, notably ITRS; these are not equivalent to ETRS89. The difference between ITRS and ETRS89 is in the order of 0.25 m (in 1999), and growing by 0.025 m per year in UK and Ireland. This effect is only relevant in international scientific applications. **For all navigation, mapping, GIS, and engineering applications within the tectonically stable parts of Europe (including UK and Ireland), the term ETRS89 should be taken as synonymous with WGS84**.

In essence, this means that anywhere you see ETRS89 in this README, you can substitute WGS84. 

## What CRS Are My Data In
- if you have latitude and longitude coordinates: 
    - They're probably [WGS84](http://spatialreference.org/ref/epsg/wgs-84/). Everything's fine!
- if you got your coordinates from a smartphone or a consumer GPS:
    - They're probably [WGS84](http://spatialreference.org/ref/epsg/wgs-84/). Everything's fine!
- if you have x and y coordinates, or you got your coordinates from Google Maps or Bing Maps and they look something like `(-626172.1357121646, 6887893.4928337997)`, or the phrase "Spherical Mercator" is mentioned anywhere:
    - they're probably in [Web Mercator](http://spatialreference.org/ref/sr-org/6864/). You **must** convert them to WGS84 first. Use `convert_epsg3857_to_wgs84([x_coordinates], [y_coordinates])` to do so.

# Accuracy
`convert_bng` and `convert_lonlat` first use the standard seven-step [Helmert transform](https://en.wikipedia.org/wiki/Helmert_transformation) to convert coordinates. This is fast, but not particularly accurate – it can introduce positional error up to approximately 5 metres. For most applications, this is not of particular concern – the input data (especially those originating with smartphone GPS) probably exceed this level of error in any case. In order to adjust for this, the OSTN15 adjustments for the kilometer-grid the ETRS89 point falls in are retrieved, and a linear interpolation to give final, accurate coordinates is carried out. This process happens in reverse for `convert_lonlat`.

## OSTN15
[OSTN15](https://www.ordnancesurvey.co.uk/business-and-government/help-and-support/navigation-technology/os-net/surveying.html) data are used for highly accurate conversions from ETRS89 latitude and longitude, or ETRS89 Eastings and Northings to OSGB36 Eastings and Northings, and vice versa. These data will usually have been recorded using the [National GPS Network](https://www.ordnancesurvey.co.uk/business-and-government/products/os-net/index.html):

### Accuracy of *Your* Data
Conversion of your coordinates using OSTN15 transformations will be accurate, but if you're using consumer equipment, or got your data off the web, be aware that you're converting coordinates which probably weren't accurately recorded in the first place. That's because [accurate surveying is difficult](https://www.ordnancesurvey.co.uk/business-and-government/help-and-support/navigation-technology/os-net/surveying.html).

### Accuracy of the OSTN15 transformation used in this library
- ETRS89 longitude and latitude / Eastings and Northings to OSGB36 conversion agrees with the provided Ordnance Survey test data in **31 of the 42** test coordinates (excluding two coordinates designed to return no data; these correctly fail).
- The 11 discrepancies are of **1mm** in each case.
- OSGB36 to ETRS89 longitude and latitude conversion is accurate to within 8 decimal places, or 1.1mm.

### A Note on Ellipsoids
WGS84 and ETRS89 coordinates use the GRS80 ellipsoid, whereas OSGB36 uses the Airy 1830 ellipsoid, which provides a regional best fit for Britain. Positions for coordinates in Great Britain can differ by over 100m as a result. It is thus inadvisable to attempt calculations using mixed ETRS89 and OSGB36 coordinates.

[![OSTN15](ostn002_s.gif)]( "OSTN15")

## Implementation
The main detail of interest is the FFI interface between Python and Rust, the Python side of which can be found in [util.py](https://github.com/urschrei/convertbng/blob/master/convertbng/util.py#L64-L100) (the `ctypes` implementation), [cutil.pyx](https://github.com/urschrei/convertbng/blob/master/convertbng/cutil.pyx#L51-L86) (the `cython` implementation), and the Rust side of which can be found in [ffi.rs](https://github.com/urschrei/rust_bng/blob/master/src/ffi.rs#L47-L271).  
The [ctypes](https://docs.python.org/2/library/ctypes.html) library expects C-compatible data structures, which we define in Rust (see above). We then define methods which allow us to receive, safely access, return, and free data across the FFI boundary.  
Finally, we link the Rust conversion functions from `util.py` [again](https://github.com/urschrei/convertbng/blob/master/convertbng/util.py#L103-L205). Note the `errcheck` assignments, which convert the FFI-compatible ctypes data structures to tuple lists. 

# Building the binary for local development
- ensure you have Rust 1.x and Cargo [installed](https://www.rustup.rs)
- clone https://github.com/urschrei/lonlat_bng, and ensure it's adjacent to this dir (i.e. `code/witnessme/convertbng` and `code/witnessme/rust_bng`)
- in this dir, run `make clean` then `make`

# Tests
You can run the Python module tests by running "make test".  
Tests require both `numpy` and `nose`.

# License
[MIT](license.txt)
