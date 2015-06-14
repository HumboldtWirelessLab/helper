<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output method='text'/>


    <xsl:variable name='newline'><xsl:text>
</xsl:text></xsl:variable>

     <xsl:template match="text( )|@*">
      <!--<xsl:value-of select="."/>-->
     </xsl:template>

    <xsl:template match="linktable">
	<xsl:value-of select="@id" /><xsl:text> </xsl:text>
	<xsl:value-of select="@id" /><xsl:text> 0</xsl:text><xsl:value-of select="$newline" />
	<xsl:for-each select="link">
	    <xsl:if test="@from=../@id">
		    <xsl:if test="@metric &lt; 9999">
			<xsl:value-of select="@from" /><xsl:text> </xsl:text>
			<xsl:value-of select="@to" /><xsl:text> </xsl:text>
			<xsl:value-of select="@metric" /><xsl:value-of select="$newline" />
		</xsl:if>
	    </xsl:if>
	</xsl:for-each>
    </xsl:template>

</xsl:stylesheet>
