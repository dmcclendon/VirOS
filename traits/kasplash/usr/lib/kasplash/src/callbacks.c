#ifdef HAVE_CONFIG_H
#  include <config.h>
#endif

#include <gtk/gtk.h>

#include "callbacks.h"
#include "interface.h"
#include "support.h"


gboolean
on_splashscreen_destroy_event          (GtkWidget       *widget,
                                        GdkEvent        *event,
                                        gpointer         user_data)
{

  return FALSE;
}


gboolean
on_splashscreen_key_press_event        (GtkWidget       *widget,
                                        GdkEventKey     *event,
                                        gpointer         user_data)
{

  return FALSE;
}


gboolean
on_splashscreen_configure_event        (GtkWidget       *widget,
                                        GdkEventConfigure *event,
                                        gpointer         user_data)
{

  return FALSE;
}

