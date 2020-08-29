LIBFFMPEG = $(SLIBPREF)ffmpeg$(SLIBSUF)
LIBFFMPEG_LINK = $(LD) -shared -Wl,-soname,$(LIBFFMPEG) -Wl,-Bsymbolic -Wl,-z,now -Wl,-z,relro -Wl,-z,defs -Wl,--gc-sections $(LDFLAGS) $(LDLIBFLAGS) -o $(LIBFFMPEG)

ifeq ($(CONFIG_SHARED),yes)
LIBFFMPEG_DEPS = libavcodec/$(SLIBPREF)avcodec$(SLIBSUF) libavformat/$(SLIBPREF)avformat$(SLIBSUF) libavutil/$(SLIBPREF)avutil$(SLIBSUF)
else
LIBFFMPEG_DEPS = libavcodec/$(LIBPREF)avcodec$(LIBSUF) libavformat/$(LIBPREF)avformat$(LIBSUF) libavutil/$(LIBPREF)avutil$(LIBSUF) libswresample/$(LIBPREF)swresample$(LIBSUF)
endif

$(LIBFFMPEG): $(LIBFFMPEG_DEPS)
ifeq ($(CONFIG_SHARED),yes)
	$(LIBFFMPEG_LINK) -Wl,--no-as-needed -lavcodec -lavformat -lavutil
else
	$(LIBFFMPEG_LINK) -Wl,--whole-archive $^ -Wl,--no-whole-archive $(EXTRALIBS-avcodec) $(EXTRALIBS-avformat) $(EXTRALIBS-avutil) $(EXTRALIBS-swresample)
endif

libffmpeg: $(LIBFFMPEG)

install-libffmpeg: $(LIBFFMPEG)
	$(Q)mkdir -p "$(SHLIBDIR)/chromium"
	$(INSTALL) -m 755 $< "$(SHLIBDIR)/chromium/$<"
	$(STRIP) "$(SHLIBDIR)/chromium/$<"

uninstall-libffmpeg:
	$(RM) "$(SHLIBDIR)/chromium/$(LIBFFMPEG)"

.PHONY: libffmpeg install-libffmpeg uninstall-libffmpeg 
