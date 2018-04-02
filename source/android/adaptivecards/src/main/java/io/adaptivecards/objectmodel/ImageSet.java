/* ----------------------------------------------------------------------------
 * This file was automatically generated by SWIG (http://www.swig.org).
 * Version 3.0.12
 *
 * Do not make changes to this file unless you know what you are doing--modify
 * the SWIG interface file instead.
 * ----------------------------------------------------------------------------- */

package io.adaptivecards.objectmodel;

public class ImageSet extends BaseCardElement {
  private transient long swigCPtr;
  private transient boolean swigCMemOwnDerived;

  protected ImageSet(long cPtr, boolean cMemoryOwn) {
    super(AdaptiveCardObjectModelJNI.ImageSet_SWIGSmartPtrUpcast(cPtr), true);
    swigCMemOwnDerived = cMemoryOwn;
    swigCPtr = cPtr;
  }

  protected static long getCPtr(ImageSet obj) {
    return (obj == null) ? 0 : obj.swigCPtr;
  }

  protected void finalize() {
    delete();
  }

  public synchronized void delete() {
    if (swigCPtr != 0) {
      if (swigCMemOwnDerived) {
        swigCMemOwnDerived = false;
        AdaptiveCardObjectModelJNI.delete_ImageSet(swigCPtr);
      }
      swigCPtr = 0;
    }
    super.delete();
  }

  public ImageSet() {
    this(AdaptiveCardObjectModelJNI.new_ImageSet__SWIG_0(), true);
  }

  public ImageSet(Spacing spacing, boolean separation) {
    this(AdaptiveCardObjectModelJNI.new_ImageSet__SWIG_1(spacing.swigValue(), separation), true);
  }

  public ImageSet(Spacing spacing, boolean separation, ImageVector images) {
    this(AdaptiveCardObjectModelJNI.new_ImageSet__SWIG_2(spacing.swigValue(), separation, ImageVector.getCPtr(images), images), true);
  }

  public JsonValue SerializeToJsonValue() {
    return new JsonValue(AdaptiveCardObjectModelJNI.ImageSet_SerializeToJsonValue(swigCPtr, this), true);
  }

  public ImageSize GetImageSize() {
    return ImageSize.swigToEnum(AdaptiveCardObjectModelJNI.ImageSet_GetImageSize(swigCPtr, this));
  }

  public void SetImageSize(ImageSize value) {
    AdaptiveCardObjectModelJNI.ImageSet_SetImageSize(swigCPtr, this, value.swigValue());
  }

  public ImageVector GetImages() {
    return new ImageVector(AdaptiveCardObjectModelJNI.ImageSet_GetImages__SWIG_0(swigCPtr, this), false);
  }

  public static ImageSet dynamic_cast(BaseCardElement baseCardElement) {
    long cPtr = AdaptiveCardObjectModelJNI.ImageSet_dynamic_cast(BaseCardElement.getCPtr(baseCardElement), baseCardElement);
    return (cPtr == 0) ? null : new ImageSet(cPtr, true);
  }

}