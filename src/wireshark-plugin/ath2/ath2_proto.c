#include "ath2_proto.h"
#include "athdesc.h"

/* ATH_HEADER = 32
 * Desc header is starting with 8 Bytes offset from beginning
 * ATH2_HEADER = 44
 */

/* forward declaration */
void proto_register_ath2();
void proto_reg_handoff_ath2();
static void dissect_ath2(tvbuff_t *tvb, packet_info *pinfo, proto_tree *tree);

static int proto_ath2 = -1;
static int global_ath2_port = 0;       //TODO: not needed
static dissector_handle_t ath2_handle;

static int hf_ath2_frame_len = -1;
static int hf_ath2_reserved = -1;
static int hf_ath2_power = -1;
static int hf_ath2_rts_cts = -1;
static int hf_ath2_voel = -1;
static int hf_ath2_clear_dest_mask = -1;
static int hf_ath2_ant_mode_xmit = -1;
static int hf_ath2_inter_req = -1;
static int hf_ath2_encrypt_key_valid = -1;
static int hf_ath2_cts_enable = -1;

static int hf_ath2_buf_len = -1;
static int hf_ath2_more = -1;
static int hf_ath2_encrypt_key_index = -1;
static int hf_ath2_frame_type = -1;
static int hf_ath2_no_ack = -1;
static int hf_ath2_comp_proc = -1;
static int hf_ath2_comp_iv_len = -1;
static int hf_ath2_comp_icv_len = -1;
static int hf_ath2_reserved_31 = -1;

static int hf_ath2_rts_duration = -1;
static int hf_ath2_duration_update_enable = -1;
static int hf_ath2_xmit_tries0 = -1;
static int hf_ath2_xmit_tries1 = -1;
static int hf_ath2_xmit_tries2 = -1;
static int hf_ath2_xmit_tries3 = -1;

static int hf_ath2_rate_0 = -1;
static int hf_ath2_rate_1 = -1;
static int hf_ath2_rate_2 = -1;
static int hf_ath2_rate_3 = -1;
static int hf_ath2_rts_cts_rate = -1;
static int hf_ath2_reserved_25_31 = -1;

static gint ett_ath2 = -1;

/* Setup protocol subtree array */
static gint *ett[] = {
        &ett_ath2
};

static hf_register_info hf_ath_tx_ctrl[] = {
	{ &hf_ath2_frame_len,
		{ "Framelen", "ath2.framelen",
		FT_UINT16, BASE_DEC,
		NULL, 0xfff0,
		NULL, HFILL }
	},
	{ &hf_ath2_reserved,
		{ "reserved", "ath2.reserved",
		FT_UINT16, BASE_DEC,
		NULL, 0x000f,
		NULL, HFILL }
	},
	{ &hf_ath2_power,
		{ "Power", "ath2.power",
		FT_UINT8, BASE_DEC,
		NULL, 0x3f,
		NULL, HFILL }
	},
	{ &hf_ath2_rts_cts,
		{ "RTS/CTS-Enable", "ath2.rtscts",
		FT_UINT8, BASE_DEC,
		NULL, 0x40,
		NULL, HFILL }
	},
	{ &hf_ath2_voel,
		{ "Voel", "ath2.voel",
		FT_UINT8, BASE_DEC,
		NULL, 0x80,
		NULL, HFILL }
	},
	{ &hf_ath2_clear_dest_mask,
		{ "Clear Dest Mask", "ath2.cleardestmask",
		FT_UINT8, BASE_DEC,
		NULL, 0x01,
		NULL, HFILL }
	},
	{ &hf_ath2_ant_mode_xmit,
		{ "Ant Mode Xmit", "ath2.ant_mode_xmit",
		FT_UINT8, BASE_DEC,
		NULL, 0x1e,
		NULL, HFILL }
	},
	{ &hf_ath2_inter_req,
		{ "Inter Req", "ath2.inter_req",
		FT_UINT8, BASE_DEC,
		NULL, 0x20,
		NULL, HFILL }
	},
	{ &hf_ath2_encrypt_key_valid,
		{ "Encrypt Key Valid", "ath2.encrypt_key_valid",
		FT_UINT8, BASE_DEC,
		NULL, 0x40,
		NULL, HFILL }
	},
	{ &hf_ath2_cts_enable,
		{ "CTS Enable", "ath2.cts_enable",
		FT_UINT8, BASE_DEC,
		NULL, 0x80,
		NULL, HFILL }
	},
	{ &hf_ath2_buf_len,
		{ "Buffer Length", "ath2.buf_len",
		FT_UINT32, BASE_DEC,
		NULL, 0xfff,
		NULL, HFILL }
	},
	{ &hf_ath2_more,
		{ "More", "ath2.more",
		FT_UINT32, BASE_DEC,
		NULL, 0x1000,
		NULL, HFILL }
	},
	{ &hf_ath2_encrypt_key_index,
		{ "Encrypt Key valid", "ath2.encrypt_key_index",
		FT_UINT32, BASE_DEC,
		NULL, 0xfe000,
		NULL, HFILL }
	},
	{ &hf_ath2_frame_type,
		{ "Frame Type", "ath2.frame_type",
		FT_UINT32, BASE_DEC,
		NULL, 0xf00000,
		NULL, HFILL }
	},
	{ &hf_ath2_no_ack,
		{ "No Ack", "ath2.no_ack",
		FT_UINT32, BASE_DEC,
		NULL, 0x1000000,
		NULL, HFILL }
	},
	{ &hf_ath2_comp_proc,
		{ "Comp proc", "ath2.comp_proc",
		FT_UINT32, BASE_DEC,
		NULL, 0x6000000,
		NULL, HFILL }
	},
	{ &hf_ath2_comp_iv_len,
		{ "IV Len", "ath2.iv_len",
		FT_UINT32, BASE_DEC,
		NULL, 0x18000000,
		NULL, HFILL }
	},
	{ &hf_ath2_comp_icv_len,
		{ "ICV Len", "ath2.icv_len",
		FT_UINT32, BASE_DEC,
		NULL, 0x60000000,
		NULL, HFILL }
	},
	{ &hf_ath2_reserved_31,
		{ "Reserved", "ath2.reserved_31",
		FT_UINT32, BASE_DEC,
		NULL, 0x80000000,
		NULL, HFILL }
	},
	{ &hf_ath2_rts_duration,
		{ "RTS Duration", "ath2.rts_duration",
		FT_UINT32, BASE_DEC,
		NULL, 0xfffe0000,
		NULL, HFILL }
	},
	{ &hf_ath2_duration_update_enable,
		{ "Duration Update Enable", "ath2.duration_update_enable",
		FT_UINT32, BASE_DEC,
		NULL, 0x10000,
		NULL, HFILL }
	},
	{ &hf_ath2_xmit_tries0,
		{ "Tries 0", "ath2.xmit_tries0",
		FT_UINT32, BASE_DEC,
		NULL, 0x0f00,
		NULL, HFILL }
	},
	{ &hf_ath2_xmit_tries1,
		{ "Tries 1", "ath2.xmit_tries1",
		FT_UINT32, BASE_DEC,
		NULL, 0xf000,
		NULL, HFILL }
	},
	{ &hf_ath2_xmit_tries2,
		{ "Tries 2", "ath2.xmit_tries2",
		FT_UINT32, BASE_DEC,
		NULL, 0x000f,
		NULL, HFILL }
	},
	{ &hf_ath2_xmit_tries3,
		{ "Tries 3", "ath2.xmit_tries3",
		FT_UINT32, BASE_DEC,
		NULL, 0x00f0,
		NULL, HFILL }
	},
	{ &hf_ath2_rate_0,
		{ "Rate 0", "ath2.rate0",
		FT_UINT32, BASE_DEC,
		NULL, 0xf8000000,
		NULL, HFILL }
	},
	{ &hf_ath2_rate_1,
		{ "Rate 1", "ath2.rate1",
		FT_UINT32, BASE_DEC,
		NULL, 0x07c00000,
		NULL, HFILL }
	},
	{ &hf_ath2_rate_2,
		{ "Rate 2", "ath2.rate2",
		FT_UINT32, BASE_DEC,
		NULL, 0x003e0000,
		NULL, HFILL }
	},
	{ &hf_ath2_rate_3,
		{ "Rate 3", "ath2.rate3",
		FT_UINT32, BASE_DEC,
		NULL, 0x0001f000,
		NULL, HFILL }
	},
	{ &hf_ath2_rts_cts_rate,
		{ "RTS/CTS Rate", "ath2.rts_cts_rate",
		FT_UINT32, BASE_DEC,
		NULL, 0x00000f80,
		NULL, HFILL }
	},
	{ &hf_ath2_reserved_25_31,
		{ "Reserved", "ath2.reserved_25_31",
		FT_UINT32, BASE_DEC,
		NULL, 0x0000007f,
		NULL, HFILL }
	}
};
   
void proto_register_ath2(void)
{
	if ( proto_ath2 == -1 ) {
	   proto_ath2 = proto_register_protocol(
	                           "ATH2-Header",
	                           "ATH2",          /* short name */
	                           "ath2"           /* abbrev */
	                   );
    }
    
    proto_register_field_array(proto_ath2, hf_ath_tx_ctrl, array_length(hf_ath_tx_ctrl));
    proto_register_subtree_array(ett, array_length(ett));
}

void proto_reg_handoff_ath2(void)
{
	static gboolean inited = FALSE;

	if (!inited) {
		ath2_handle = create_dissector_handle(dissect_ath2, proto_ath2);
		dissector_add("wtap_encap", 20, ath2_handle);

		inited = TRUE;
	}
}

static void
dissect_ath2(tvbuff_t *tvb, packet_info *pinfo, proto_tree *tree)
{
	int pos = 8;
	struct ar5212_desc *athheader = (struct ar5212_desc *)(tvb_get_ptr(tvb,8,24));
	if (check_col(pinfo->cinfo, COL_PROTOCOL)) {
		col_set_str(pinfo->cinfo, COL_PROTOCOL, "ATH2");
	}
	/* Clear out stuff in the info column */
	if (check_col(pinfo->cinfo,COL_INFO)) {
		col_clear(pinfo->cinfo,COL_INFO);
	}
	
	if (tree) { /* we are being asked for details */
		proto_item *ti = NULL;
		proto_tree *ath2_tree = NULL;
		//proto_tree *ath2_rate_tree = NULL;

		ti = proto_tree_add_item(tree, proto_ath2, tvb, pos, -1, FALSE);
		ath2_tree = proto_item_add_subtree(ti, ett_ath2);
		proto_tree_add_item(ath2_tree, hf_ath2_frame_len, tvb, pos, 2, FALSE);
		proto_tree_add_item(ath2_tree, hf_ath2_reserved, tvb, pos, 2, FALSE);

		proto_tree_add_item(ath2_tree, hf_ath2_power, tvb, pos + 2, 1, FALSE);
		proto_tree_add_item(ath2_tree, hf_ath2_rts_cts, tvb, pos + 2, 1, FALSE);
		proto_tree_add_item(ath2_tree, hf_ath2_voel, tvb, pos + 2, 1, FALSE);
		
		proto_tree_add_item(ath2_tree, hf_ath2_clear_dest_mask, tvb, pos + 3, 1, FALSE);
		proto_tree_add_item(ath2_tree, hf_ath2_ant_mode_xmit, tvb, pos + 3, 1, FALSE);
		proto_tree_add_item(ath2_tree, hf_ath2_inter_req, tvb, pos + 3, 1, FALSE);
		proto_tree_add_item(ath2_tree, hf_ath2_encrypt_key_valid, tvb, pos + 3, 1, FALSE);
		proto_tree_add_item(ath2_tree, hf_ath2_cts_enable, tvb, pos + 3, 1, FALSE);

		proto_tree_add_item(ath2_tree, hf_ath2_buf_len, tvb, pos + 4, 4, FALSE);
		proto_tree_add_item(ath2_tree, hf_ath2_more, tvb, pos + 4, 4, FALSE);
		proto_tree_add_item(ath2_tree, hf_ath2_encrypt_key_index, tvb, pos + 4, 4, FALSE);
		proto_tree_add_item(ath2_tree, hf_ath2_frame_type, tvb, pos + 4, 4, FALSE);
		proto_tree_add_item(ath2_tree, hf_ath2_no_ack, tvb, pos + 4, 4, FALSE);
		proto_tree_add_item(ath2_tree, hf_ath2_comp_proc, tvb, pos + 4, 4, FALSE);
		proto_tree_add_item(ath2_tree, hf_ath2_comp_iv_len, tvb, pos + 4, 4, FALSE);
		proto_tree_add_item(ath2_tree, hf_ath2_comp_icv_len, tvb, pos + 4, 4, FALSE);
		proto_tree_add_item(ath2_tree, hf_ath2_reserved_31, tvb, pos + 4, 4, FALSE);

		proto_tree_add_item(ath2_tree, hf_ath2_rts_duration, tvb, pos + 8, 4, FALSE);
		proto_tree_add_item(ath2_tree, hf_ath2_duration_update_enable, tvb, pos + 8, 4, FALSE);

		proto_tree_add_item(ath2_tree, hf_ath2_xmit_tries0, tvb, pos + 8, 4, FALSE);
		proto_tree_add_item(ath2_tree, hf_ath2_xmit_tries1, tvb, pos + 8, 4, FALSE);
		proto_tree_add_item(ath2_tree, hf_ath2_xmit_tries2, tvb, pos + 8, 4, FALSE);
		proto_tree_add_item(ath2_tree, hf_ath2_xmit_tries3, tvb, pos + 8, 4, FALSE);

        //ti = proto_tree_add_item(ath2_tree, proto_ath2, tvb, pos, 4, FALSE);
		//ath2_rate_tree = proto_item_add_subtree(ti, ett_ath2);

		proto_tree_add_item(ath2_tree, hf_ath2_rate_0, tvb, pos + 12, 4, FALSE);
		proto_tree_add_item(ath2_tree, hf_ath2_rate_1, tvb, pos + 12, 4, FALSE);
		proto_tree_add_item(ath2_tree, hf_ath2_rate_2, tvb, pos + 12, 4, FALSE);
		proto_tree_add_item(ath2_tree, hf_ath2_rate_3, tvb, pos + 12, 4, FALSE);
		proto_tree_add_item(ath2_tree, hf_ath2_rts_cts_rate, tvb, pos + 12, 4, FALSE);
		proto_tree_add_item(ath2_tree, hf_ath2_reserved_25_31, tvb, pos + 12, 4, FALSE);
		
		proto_item_append_text(ti, " Rate0 %d ", athheader->xmit_rate0);
		proto_item_append_text(ti, " Power %d ", athheader->xmit_power);
		proto_item_append_text(ti, " ACK %d ", athheader->no_ack);
		proto_item_append_text(ti, " Rate0 %d ", athheader->xmit_tries1);
		
		
	}

}



