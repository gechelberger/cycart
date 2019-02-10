from setuptools import setup
from setuptools.extension import Extension

try:
    from Cython.Distutils import build_ext
except ImportError:
    use_cython = False
else:
    use_cython = True

#todo: handle install if numpy not found

library_name = 'cycart'
def make_sources(*module_names, package_names=()):
    file_type = '.pyx' if use_cython else '.cpp'
    return {
        '.'.join([library_name, *package_names, module_name]) :
            '/'.join([library_name, *package_names, module_name + file_type])
        for module_name in module_names
    }

sources = make_sources(
    'space',
    'line',
    'segment',
    'circle',
    'does_intersect',
    'intersect',
    'polygon',
    #'rasterize',
)

extensions = [
    Extension(
        module_name,
        sources=[source],
        language='c++',
        include_dirs=['cycart/'],
        libraries=[],
        extra_compile_args=['-O3'],
    )
    for module_name, source in sources.items()
]

extensions.extend([
    Extension(
        'cycart.alg.convexhull',
        sources=['cycart/alg/convexhull.pyx'],
        language='c++',
        include_dirs=[],
        extra_compile_args=['-O3']
    ),
    Extension(
        'cycart.alg.pointsort',
        sources=['cycart/alg/pointsort.pyx'],
        language='c++'
    )
])


CMDCLASS = {}
if use_cython:
    CMDCLASS['build_ext'] = build_ext

INSTALL_REQUIRES = ["multipledispatch", "numpy"]

TEST_LIBS = ["pytest"]
DEV_LIBS = ["cython", "tox"]
EXTRAS_REQUIRE = {
    "test" : TEST_LIBS,
    "dev" : DEV_LIBS
}

setup(
    name=library_name,
    author="Greg Echelberger",
    author_name="gechelberger@gmail.com",
    url="https://github.com/gechelberger/cycart",
    version="1.0.0a1",
    description="cython R2 euclidean geometry utility library",
    packages=['cycart'],
    cmdclass=CMDCLASS,
    setup_requires=["wheel", "numpy"],
    install_requires=INSTALL_REQUIRES,
    extras_require=EXTRAS_REQUIRE,
    ext_modules=extensions,
    package_data={
        'cycart' : ['*.pyx', '*.pxd', '*.cpp'],
        'cycart.native' : ['*.pxd'],
        'cycart.alg' : ['*.pyx', '*.pxd', '*.cpp']
    },
    zip_safe=False,
)