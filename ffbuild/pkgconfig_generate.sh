#!/bin/sh

. ffbuild/config.sh

if test "$shared" = "yes"; then
    shared=true
else
    shared=false
fi

shortname=$1
name=lib${shortname}
fullname=${name}${build_suffix}
comment=$2
libs=$(eval echo \$extralibs_${shortname})
deps=$(eval echo \$${shortname}_deps)
libs_cuda="/usr/cuda/lib64/libcublasLt_static.a /usr/cuda/lib64/libcublas_static.a /usr/cuda/lib64/libcudadevrt.a /usr/cuda/lib64/libcudart_static.a /usr/cuda/lib64/libcufft_static_nocallback.a /usr/cuda/lib64/libcufftw_static.a /usr/cuda/lib64/libculibos.a /usr/cuda/lib64/libcurand_static.a /usr/cuda/lib64/libcusolver_static.a /usr/cuda/lib64/libcusparse_static.a /usr/cuda/lib64/liblapack_static.a /usr/cuda/lib64/libmetis_static.a /usr/cuda/lib64/libnvjpeg_static.a"
libs_nvidia="-L/usr/nvidia/lib -lGL -lEGL -lGLX -lnvcuvid"

for dep in $deps; do
    depname=lib${dep}
    fulldepname=${depname}${build_suffix}
    . ${depname}/${depname}.version
    depversion=$(eval echo \$${depname}_VERSION)
    requires="$requires ${fulldepname} >= ${depversion}, "
done
requires=${requires%, }

version=$(grep ${name}_VERSION= $name/${name}.version | cut -d= -f2)

cat <<EOF > $name/$fullname.pc
prefix=$prefix
exec_prefix=\${prefix}
libdir=$libdir
includedir=$incdir

Name: $fullname
Description: $comment
Version: $version
Requires: $($shared || echo $requires)
Requires.private: $($shared && echo $requires)
Conflicts:
Libs: -L\${libdir} $($shared && echo -l${fullname#lib} || echo /usr/lib64/${fullname}.a) $($shared || echo $libs_cuda $libs_nvidia $libs)
Libs.private: $($shared && echo $libs_cuda $libs_nvidia $libs)
Cflags: -I\${includedir}
EOF

mkdir -p doc/examples/pc-uninstalled
includedir=${source_path}
[ "$includedir" = . ] && includedir="\${pcfiledir}/../../.."
    cat <<EOF > doc/examples/pc-uninstalled/${name}-uninstalled.pc
prefix=
exec_prefix=
libdir=\${pcfiledir}/../../../$name
includedir=${source_path}

Name: $fullname
Description: $comment
Version: $version
Requires: $requires
Conflicts:
Libs: -L\${libdir} $($shared && echo -l${fullname#lib} || echo /usr/lib64/${fullname}.a) $($shared || echo $libs_cuda $libs_nvidia $libs)
Cflags: -I\${includedir}
EOF
