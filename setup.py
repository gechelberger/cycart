from setuptools import setup
from setuptools.extension import Extension

try:
    from Cython.Distutils import build_ext
except ImportError:
    use_cython = False
else:
    use_cython = True

package_name = 'cycart'
def make_sources(*module_names):
    file_type = '.pyx' if use_cython else '.cpp'
    return {
        package_name + '.' + module_name : package_name + "/" + module_name + file_type
        for module_name in module_names
    }

sources = make_sources(
    'space',
    'line',
    'segment',
    'circle',
    'does_intersect',
    'intersect',
    #'polygon',
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

CMDCLASS = {}
if use_cython:
    CMDCLASS['build_ext'] = build_ext

INSTALL_REQUIRES = ["multipledispatch"]

TEST_LIBS = ["pytest"]
DEV_LIBS = ["cython", "tox"]
EXTRAS_REQUIRE = {
    "test" : TEST_LIBS,
    "dev" : DEV_LIBS
}

setup(
    name=package_name,
    author="Greg Echelberger",
    author_name="gechelberger@gmail.com",
    url="https://github.com/gechelberger/cycart",
    version="1.0.0a1",
    description="cython R2 euclidean geometry utility library",
    packages=['cycart'],
    cmdclass=CMDCLASS,
    setup_requires=["wheel"],
    install_requires=INSTALL_REQUIRES,
    extras_require=EXTRAS_REQUIRE,
    ext_modules=extensions,
    package_data={
        'cycart' : ['*.pyx', '*.pxd', '*.cpp']
    },
    zip_safe=False,
)