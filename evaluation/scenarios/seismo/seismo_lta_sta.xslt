<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output method='text'/>

    <xsl:variable name='newline'><xsl:text>
</xsl:text></xsl:variable>

    <xsl:template match="text( )|@*">
      <!--<xsl:value-of select="."/>-->
    </xsl:template>

    <xsl:template match="seismodetection_stalta/alarmlist/alarm">
	<xsl:value-of select="../../@id" /><xsl:text>,</xsl:text>
	<xsl:value-of select="@start" /><xsl:text>,</xsl:text>
	<xsl:value-of select="@end" /><xsl:value-of select="$newline" />
    </xsl:template>

</xsl:stylesheet>