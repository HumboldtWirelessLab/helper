#ifdef HAVE_CONFIG_H
# include "config.h"
#endif

#include <gmodule.h>

#include "moduleinfo.h"

#ifndef ENABLE_STATIC
G_MODULE_EXPORT void plugin_register(void);
G_MODULE_EXPORT void plugin_reg_handoff(void);

G_MODULE_EXPORT const gchar version[] = VERSION;

/* Start the functions we need for the plugin stuff */

G_MODULE_EXPORT void
plugin_register(void)
{
	{
		extern void proto_register_ath2(void);
		proto_register_ath2();
	}
}

G_MODULE_EXPORT void
plugin_reg_handoff(void)
{
	{
		extern void proto_reg_handoff_ath2(void);
		proto_reg_handoff_ath2();
	}
}
#endif
