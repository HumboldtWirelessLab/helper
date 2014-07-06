<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output method='text'/>

    <xsl:variable name='newline'><xsl:text>
</xsl:text></xsl:variable>

    <xsl:template match="text( )|@*">
      <!--<xsl:value-of select="."/>-->
    </xsl:template>

    <xsl:template match="/">
	<xsl:value-of select="count(//flooding)" /><xsl:text>,</xsl:text>
	<xsl:value-of select="sum(//flooding/localstats/@received_new)" /><xsl:text>,</xsl:text>
	<xsl:value-of select="(((sum(//flooding/localstats/@received_new) + sum(//flooding/localstats/@source_new)) div ((count(//flooding) * (sum(//flooding/localstats/@source_new))))))" /><xsl:text>,</xsl:text>
	<xsl:value-of select="sum(//flooding/localstats/@source)" /><xsl:text>,</xsl:text>
	<xsl:value-of select="sum(//flooding/localstats/@received)" /><xsl:text>, </xsl:text>
	
	<xsl:value-of select="sum(//flooding/localstats/@sent)" /><xsl:text>,</xsl:text>
	<xsl:value-of select="sum(//flooding/localstats/@forward)" /><xsl:text>,</xsl:text>
	<xsl:value-of select="sum(//flooding/localstats/@passive)" /><xsl:text>,</xsl:text>
	<xsl:value-of select="sum(//flooding/localstats/@forward_new)" /><xsl:text>,</xsl:text>
	<xsl:value-of select="sum(//flooding/localstats/@source_new)" /><xsl:text>, </xsl:text>
	
	<xsl:value-of select="sum(//flooding/localstats/@passive)" /><xsl:text>,</xsl:text>
	<xsl:value-of select="sum(//flooding/localstats/@rx_ack)" /><xsl:text>,</xsl:text>
	<xsl:value-of select="sum(//flooding/localstats/@low_layer_reject)" /><xsl:text>,</xsl:text>
	<xsl:value-of select="sum(//flooding/localstats/@passive_acked_dst)" /><xsl:text>,</xsl:text>
	<xsl:value-of select="sum(//flooding/localstats/@passive_not_acked_dst)" /><xsl:text>, </xsl:text>
	
	<xsl:value-of select="sum(//flooding/localstats/@passive_force_dst)" /><xsl:text>,</xsl:text>
	<xsl:value-of select="sum(//flooding/localstats/@finished)" /><xsl:text>,</xsl:text>
	<xsl:value-of select="sum(//flooding/localstats/@finished_src)" /><xsl:text>,</xsl:text>
	<xsl:value-of select="sum(//flooding/localstats/@finished_dst)" /><xsl:text>,</xsl:text>
	<xsl:value-of select="sum(//flooding/localstats/@finished_piggyback)" /><xsl:text>, </xsl:text>
	
	<xsl:value-of select="sum(//flooding/localstats/@resp_piggyback)" /><xsl:text>,</xsl:text>
	<xsl:value-of select="sum(//flooding/localstats/@finished_passive_src)" /><xsl:text>,</xsl:text>
	<xsl:value-of select="sum(//flooding/localstats/@finished_passive_dst)" /><xsl:text>,</xsl:text>
	<xsl:value-of select="sum(//flooding/localstats/@txaborts)" /><xsl:text>,</xsl:text>
	<xsl:value-of select="sum(//flooding/localstats/@tx_aborts_errors)" /><xsl:value-of select="$newline" />
    </xsl:template>
</xsl:stylesheet>