#include <gtk/gtk.h>


gboolean
on_splashscreen_destroy_event          (GtkWidget       *widget,
                                        GdkEvent        *event,
                                        gpointer         user_data);

gboolean
on_splashscreen_key_press_event        (GtkWidget       *widget,
                                        GdkEventKey     *event,
                                        gpointer         user_data);

gboolean
on_splashscreen_configure_event        (GtkWidget       *widget,
                                        GdkEventConfigure *event,
                                        gpointer         user_data);
