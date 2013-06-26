<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output method='xml'/>

    <xsl:template match="text()|@*">
      <!--<xsl:value-of select="."/>-->
    </xsl:template>

    <xsl:template match="/">
        <res>
            <xsl:attribute name="source">
                <xsl:value-of select="//flooding/source[@count &gt; 0]/../@node" />
            </xsl:attribute>

            <xsl:attribute name="number_of_flooding_reqs">
                <xsl:value-of select="//flooding/source[@count &gt; 0]/@count" />
            </xsl:attribute>

            <xsl:attribute name="cnt_nodes">
                <xsl:value-of select="count(//flooding)" />
            </xsl:attribute>

            <xsl:attribute name="total_forwards">
                <xsl:value-of select="sum(//flooding/forward/@count)" />
            </xsl:attribute>

            <xsl:attribute name="means_forwards_per_node">
           	    <xsl:value-of select="(sum(//flooding/forward/@count) div (count(//flooding) - 1))" />
            </xsl:attribute>

            <xsl:attribute name="number_of_flooding_replies">
           	    <xsl:value-of select="sum(//flooding/source/@count)" />
            </xsl:attribute>
        </res>

    </xsl:template>
</xsl:stylesheet>