;
; Open SLC files.
;
; Parames:
;
; Keywords:
;
; Example:
;
; Written by:
;   T.LI @ Sasmac, 20141224
;
PRO TLI_SMC_OPEN_SLC

  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  ;-----------------------------------------------
  ; GUI info.
  path = config.workpath
  
  default_filters = ['*.slc;*.rslc']
  
  inputfile = DIALOG_PICKFILE(TITLE='Open SLC file', DIALOG_PARENT=wid.base, $
    FILTER = default_filters, /MUST_EXIST, GET_PATH=workpath, path=path)
  IF inputfile EQ '' THEN RETURN
  IF strlen(inputfile) gt 0 then BEGIN
    config.workpath = workpath
  ENDIF ELSE BEGIN
    IF file_dirname(inputfile,/mark_directory) ne config.temppath then config.workpath = file_dirname(inputfile,/mark_directory)
  ENDELSE
  
  IF STRLEN(inputfile) EQ 0 OR NOT FILE_TEST(inputfile) THEN BEGIN
    TLI_SMC_DUMMY, inputstr='TLI_SMC_OPEN_SLC: Input file not exist:'+inputfile
    RETURN
  ENDIF
  
  ; Update definitions info
  TLI_SMC_DEFINITIONS_UPDATE, inputfile=inputfile
  file.name=inputfile

  ; change mousepointer
  WIDGET_CONTROL,/hourglass
  
  ;------------------------------------------------------
  ; Read par file
  IF NOT FILE_TEST(inputfile+'.par') THEN BEGIN
    TLI_SMC_DUMMY, inputstr='TLI_SMC_OPEN_SLC: Par file not exist:'+inputfile+'.par'
    RETURN
  ENDIF
  finfo=TLI_LOAD_SLC_PAR(inputfile+'.par')
  sz=SIZE(finfo,/DIMENSIONS)
  
  ; Read data
  data=TLI_READDATA(inputfile, samples=finfo.range_samples, format=finfo.image_format,/swap_endian)
  
  ;------------------------------------------
  ; Show data
  
  if 0 THEN BEGIN
    rrat,file.name,image,/preview
    dim = size(image)
    if dim[0] ne 0 then begin
      xdim = dim[dim[0]-1]
      if xdim ne wid.base_xsize then recalculate=1
    endif else recalculate=1
    if keyword_set(recalculate) then begin
      ;--> Generate the preview file
      preview,file.name,DIRECT=image
      progress,Message='Finalizing preview...'
      ;--> Read image and transform to byte
      ;         rrat,config.tempdir+config.lookfile,image
      image = float2bytes(temporary(image),/OVERWRITE)
      
      dim = size(image)
      xdim = dim[dim[0]-1]
      ydim = dim[dim[0]]
      srat,file.name,image,/preview
      progress,/destroy
    endif
    
    ;---------------------------------
    ; Select channels
    ;---------------------------------
    
    if not keyword_set(nodefault) then channel_default
  ENDIF
  ;---------------------------------
  ; Plotting
  ;---------------------------------
  
  sz  = size(data,/DIMENSIONS)
  file.xdim = sz[0]
  file.ydim = sz[1]
  TLI_SMC_DISPLAY,  ABS(data)^0.25
  
  
END