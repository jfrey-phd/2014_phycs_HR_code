/* ----------------------------------------------------------------------------
 * This file was automatically generated by SWIG (http://www.swig.org).
 * Version 2.0.10
 *
 * Do not make changes to this file unless you know what you are doing--modify
 * the SWIG interface file instead.
 * ----------------------------------------------------------------------------- */


public class SpeakJNI {
  public final static native int setPitch(int jarg1);
  public final static native int setAmplitude(int jarg1);
  public final static native int setPitchRange(int jarg1);
  public final static native int initialise(String jarg1, int jarg2);
  public final static native int espeak(String jarg1);
  public final static native int cancel();
  public final static native int isPlaying();
  public final static native int terminate();
  public final static native int setVoice(String jarg1);
}
