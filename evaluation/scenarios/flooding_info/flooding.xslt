<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output method='text'/>

    <xsl:variable name='newline'><xsl:text>
</xsl:text></xsl:variable>

    <xsl:template match="text( )|@*">
      <!--<xsl:value-of select="."/>-->
    </xsl:template>

    <xsl:template match="/">
            <source count="0" />
        <received count="325" />
        <sent count="97" />
        <forward count="97" />
        <passive count="0" />

	<xsl:value-of select="count(//flooding)" /><xsl:text>,</xsl:text>
	<xsl:value-of select="sum(//flooding/forward/@count)" /><xsl:text>,</xsl:text>
	<xsl:value-of select="(sum(//flooding/forward/@count) div (count(//flooding) - 1))" /><xsl:text>,</xsl:text>
	<xsl:value-of select="sum(//flooding/source/@count)" /><xsl:value-of select="$newline" />
	
    </xsl:template>
</xsl:stylesheet>