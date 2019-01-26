# CHNOSZ/vignettes/mklinks.sh
# add documentation links to anintro.html
# 20190125 jmd

# add links to help topics
# set background-image:none to remove underlines (from bootstrap theme)
sed -i 's/<code>?`CHNOSZ-package`<\/code>/<code><a href="..\/html\/CHNOSZ-package.html" style="background-image:none;">?`CHNOSZ-package`<\/a><\/code>/g' anintro.html
sed -i 's/<code>?basis<\/code>/<code><a href="..\/html\/basis.html" style="background-image:none;">?basis<\/a><\/code>/g' anintro.html
sed -i 's/<code>?mosaic<\/code>/<code><a href="..\/html\/eos.html" style="background-image:none;">?mosaic<\/a><\/code>/g' anintro.html
sed -i 's/<code>?buffer<\/code>/<code><a href="..\/html\/buffer.html" style="background-image:none;">?buffer<\/a><\/code>/g' anintro.html
sed -i 's/<code>?solubility<\/code>/<code><a href="..\/html\/solubility.html" style="background-image:none;">?solubility<\/a><\/code>/g' anintro.html
sed -i 's/<code>?ionize.aa<\/code>/<code><a href="..\/html\/ionize.aa.html" style="background-image:none;">?ionize.aa<\/a><\/code>/g' anintro.html
sed -i 's/<code>?count.aa<\/code>/<code><a href="..\/html\/util.fasta.html" style="background-image:none;">?count.aa<\/a><\/code>/g' anintro.html
sed -i 's/<code>?objective<\/code>/<code><a href="..\/html\/objective.html" style="background-image:none;">?objective<\/a><\/code>/g' anintro.html
sed -i 's/<code>?thermo<\/code>/<code><a href="..\/html\/data.html" style="background-image:none;">?thermo<\/a><\/code>/g' anintro.html
sed -i 's/<code>?hkf<\/code>/<code><a href="..\/html\/eos.html" style="background-image:none;">?hkf<\/a><\/code>/g' anintro.html
sed -i 's/<code>?cgl<\/code>/<code><a href="..\/html\/eos.html" style="background-image:none;">?cgl<\/a><\/code>/g' anintro.html
sed -i 's/<code>?water<\/code>/<code><a href="..\/html\/water.html" style="background-image:none;">?water<\/a><\/code>/g' anintro.html
sed -i 's/<code>?subcrt<\/code>/<code><a href="..\/html\/subcrt.html" style="background-image:none;">?subcrt<\/a><\/code>/g' anintro.html
sed -i 's/<code>?EOSregress<\/code>/<code><a href="..\/html\/EOSregress.html" style="background-image:none;">?EOSregress<\/a><\/code>/g' anintro.html
sed -i 's/<code>?wjd<\/code>/<code><a href="..\/html\/wjd.html" style="background-image:none;">?wjd<\/a><\/code>/g' anintro.html
sed -i 's/<code>?taxonomy<\/code>/<code><a href="..\/html\/taxonomy.html" style="background-image:none;">?taxonomy<\/a><\/code>/g' anintro.html

# add links to function names
# start at line 120 (below the TOC)
sed -i '120,$s/<code>info()<\/code>/<code><a href="..\/html\/info.html" style="background-image:none;">info()<\/a><\/code>/g' anintro.html
sed -i '120,$s/<code>ZC()<\/code>/<code><a href="..\/html\/util.formula.html" style="background-image:none;">ZC()<\/a><\/code>/g' anintro.html
sed -i '120,$s/<code>affinity()<\/code>/<code><a href="..\/html\/affinity.html" style="background-image:none;">affinity()<\/a><\/code>/g' anintro.html
sed -i '120,$s/<code>thermo.refs()<\/code>/<code><a href="..\/html\/util.data.html" style="background-image:none;">thermo.refs()<\/a><\/code>/g' anintro.html
sed -i '120,$s/<code>makeup()<\/code>/<code><a href="..\/html\/makeup.html" style="background-image:none;">makeup()<\/a><\/code>/g' anintro.html
sed -i '120,$s/<code>as.chemical.formula()<\/code>/<code><a href="..\/html\/util.formula.html" style="background-image:none;">as.chemical.formula()<\/a><\/code>/g' anintro.html
sed -i '120,$s/<code>subcrt()<\/code>/<code><a href="..\/html\/subcrt.html" style="background-image:none;">subcrt()<\/a><\/code>/g' anintro.html
sed -i '120,$s/<code>T.units()<\/code>/<code><a href="..\/html\/util.units.html" style="background-image:none;">T.units()<\/a><\/code>/g' anintro.html
sed -i '120,$s/<code>E.units()<\/code>/<code><a href="..\/html\/util.units.html" style="background-image:none;">E.units()<\/a><\/code>/g' anintro.html
sed -i '120,$s/<code>P.units()<\/code>/<code><a href="..\/html\/util.units.html" style="background-image:none;">P.units()<\/a><\/code>/g' anintro.html
sed -i '120,$s/<code>equilibrate()<\/code>/<code><a href="..\/html\/equilibrate.html" style="background-image:none;">equilibrate()<\/a><\/code>/g' anintro.html
sed -i '120,$s/<code>diagram()<\/code>/<code><a href="..\/html\/diagram.html" style="background-image:none;">diagram()<\/a><\/code>/g' anintro.html
sed -i '120,$s/<code>basis()<\/code>/<code><a href="..\/html\/basis.html" style="background-image:none;">basis()<\/a><\/code>/g' anintro.html
sed -i '120,$s/<code>species()<\/code>/<code><a href="..\/html\/species.html" style="background-image:none;">species()<\/a><\/code>/g' anintro.html
sed -i '120,$s/<code>data(thermo)<\/code>/<code><a href="..\/html\/data.html" style="background-image:none;">data(thermo)<\/a><\/code>/g' anintro.html
sed -i '120,$s/<code>describe.reaction()<\/code>/<code><a href="..\/html\/util.expression.html" style="background-image:none;">describe.reaction()<\/a><\/code>/g' anintro.html
sed -i '120,$s/<code>swap.basis()<\/code>/<code><a href="..\/html\/swap.basis.html" style="background-image:none;">swap.basis()<\/a><\/code>/g' anintro.html
sed -i '120,$s/<code>water.lines()<\/code>/<code><a href="..\/html\/util.plot.html" style="background-image:none;">water.lines()<\/a><\/code>/g' anintro.html
sed -i '120,$s/<code>ratlab()<\/code>/<code><a href="..\/html\/util.expression.html" style="background-image:none;">ratlab()<\/a><\/code>/g' anintro.html
sed -i '120,$s/<code>mosaic()<\/code>/<code><a href="..\/html\/mosaic.html" style="background-image:none;">mosaic()<\/a><\/code>/g' anintro.html
sed -i '120,$s/<code>convert()<\/code>/<code><a href="..\/html\/util.units.html" style="background-image:none;">convert()<\/a><\/code>/g' anintro.html
sed -i '120,$s/<code>mod.buffer()<\/code>/<code><a href="..\/html\/buffer.html" style="background-image:none;">mod.buffer()<\/a><\/code>/g' anintro.html
sed -i '120,$s/<code>thermo\$/<code><a href="..\/html\/data.html" style="background-image:none;">thermo<\/a>\$/g' anintro.html
sed -i '120,$s/<code>solubility()<\/code>/<code><a href="..\/html\/solubility.html" style="background-image:none;">solubility()<\/a><\/code>/g' anintro.html
sed -i '120,$s/<code>ZC.col()<\/code>/<code><a href="..\/html\/util.plot.html" style="background-image:none;">ZC.col()<\/a><\/code>/g' anintro.html
sed -i '120,$s/<code>aminoacids(\&quot;\&quot;)<\/code>/<code><a href="..\/html\/util.seq.html" style="background-image:none;">aminoacids(\&quot;\&quot;)<\/a><\/code>/g' anintro.html
sed -i '120,$s/<code>expr.species()<\/code>/<code><a href="..\/html\/util.expression.html" style="background-image:none;">expr.species()<\/a><\/code>/g' anintro.html
sed -i '120,$s/<code>nonideal()<\/code>/<code><a href="..\/html\/nonideal.html" style="background-image:none;">nonideal()<\/a><\/code>/g' anintro.html
sed -i '120,$s/<code>pinfo()<\/code>/<code><a href="..\/html\/protein.info.html" style="background-image:none;">pinfo()<\/a><\/code>/g' anintro.html
sed -i '120,$s/<code>protein.length()<\/code>/<code><a href="..\/html\/protein.info.html" style="background-image:none;">protein.length()<\/a><\/code>/g' anintro.html
sed -i '120,$s/<code>protein.formula()<\/code>/<code><a href="..\/html\/protein.info.html" style="background-image:none;">protein.formula()<\/a><\/code>/g' anintro.html
sed -i '120,$s/<code>ionize.aa()<\/code>/<code><a href="..\/html\/ionize.aa.html" style="background-image:none;">ionize.aa()<\/a><\/code>/g' anintro.html
sed -i '120,$s/<code>read.fasta()<\/code>/<code><a href="..\/html\/util.fasta.html" style="background-image:none;">read.fasta()<\/a><\/code>/g' anintro.html
sed -i '120,$s/<code>protein.basis()<\/code>/<code><a href="..\/html\/protein.info.html" style="background-image:none;">protein.basis()<\/a><\/code>/g' anintro.html
sed -i '120,$s/<code>yeastgfp()<\/code>/<code><a href="..\/html\/yeast.html" style="background-image:none;">yeastgfp()<\/a><\/code>/g' anintro.html
sed -i '120,$s/<code>unitize()<\/code>/<code><a href="..\/html\/util.misc.html" style="background-image:none;">unitize()<\/a><\/code>/g' anintro.html
sed -i '120,$s/<code>revisit()<\/code>/<code><a href="..\/html\/revisit.html" style="background-image:none;">revisit()<\/a><\/code>/g' anintro.html
sed -i '120,$s/<code>axis.label()<\/code>/<code><a href="..\/html\/util.expression.html" style="background-image:none;">axis.label()<\/a><\/code>/g' anintro.html
sed -i '120,$s/<code>yeast.aa()<\/code>/<code><a href="..\/html\/yeast.html" style="background-image:none;">yeast.aa()<\/a><\/code>/g' anintro.html
sed -i '120,$s/<code>seq2aa()<\/code>/<code><a href="..\/html\/add.protein.html" style="background-image:none;">seq2aa()<\/a><\/code>/g' anintro.html
sed -i '120,$s/<code>uniprot.aa()<\/code>/<code><a href="..\/html\/util.fasta.html" style="background-image:none;">uniprot.aa()<\/a><\/code>/g' anintro.html
sed -i '120,$s/<code>add.protein()<\/code>/<code><a href="..\/html\/add.protein.html" style="background-image:none;">add.protein()<\/a><\/code>/g' anintro.html
sed -i '120,$s/<code>aminoacids()<\/code>/<code><a href="..\/html\/util.seq.html" style="background-image:none;">aminoacids()<\/a><\/code>/g' anintro.html
sed -i '120,$s/<code>findit()<\/code>/<code><a href="..\/html\/findit.html" style="background-image:none;">findit()<\/a><\/code>/g' anintro.html
sed -i '120,$s/<code>add.obigt()<\/code>/<code><a href="..\/html\/add.obigt.html" style="background-image:none;">add.obigt()<\/a><\/code>/g' anintro.html
sed -i '120,$s/<code>mod.obigt()<\/code>/<code><a href="..\/html\/add.obigt.html" style="background-image:none;">mod.obigt()<\/a><\/code>/g' anintro.html
sed -i '120,$s/<code>today()<\/code>/<code><a href="..\/html\/add.obigt.html" style="background-image:none;">today()<\/a><\/code>/g' anintro.html
sed -i '120,$s/<code>checkGHS()<\/code>/<code><a href="..\/html\/util.data.html" style="background-image:none;">checkGHS()<\/a><\/code>/g' anintro.html
sed -i '120,$s/<code>checkEOS()<\/code>/<code><a href="..\/html\/util.data.html" style="background-image:none;">checkEOS()<\/a><\/code>/g' anintro.html
sed -i '120,$s/<code>equil.reaction()<\/code>/<code><a href="..\/html\/equilibrate.html" style="background-image:none;">equil.reaction()<\/a><\/code>/g' anintro.html
sed -i '120,$s/<code>EOSregress()<\/code>/<code><a href="..\/html\/EOSregress.html" style="background-image:none;">EOSregress()<\/a><\/code>/g' anintro.html
sed -i '120,$s/<code>wjd()<\/code>/<code><a href="..\/html\/wjd.html" style="background-image:none;">wjd()<\/a><\/code>/g' anintro.html
sed -i '120,$s/<code>RH2obigt()<\/code>/<code><a href="..\/html\/util.data.html" style="background-image:none;">RH2obigt()<\/a><\/code>/g' anintro.html
sed -i '120,$s/<code>eqdata()<\/code>/<code><a href="..\/html\/eqdata.html" style="background-image:none;">eqdata()<\/a><\/code>/g' anintro.html

# functions from R base packages
sed -i '120,$s/<code>install.packages/<code><a href="..\/..\/utils\/html\/install.packages.html" style="background-image:none;">install.packages<\/a>/g' anintro.html
sed -i '120,$s/<code>library/<code><a href="..\/..\/base\/html\/library.html" style="background-image:none;">library<\/a>/g' anintro.html
sed -i '120,$s/help()/<a href="..\/..\/utils\/html\/help.html" style="background-image:none;">help()<\/a>/g' anintro.html
sed -i '120,$s/help.start()/<a href="..\/..\/utils\/html\/help.start.html" style="background-image:none;">help.start()<\/a>/g' anintro.html
sed -i '120,$s/write.table/<a href="..\/..\/utils\/html\/write.table.html" style="background-image:none;">write.table<\/a>/g' anintro.html
sed -i '120,$s/<code>plot()<\/code>/<code><a href="..\/..\/graphics\/html\/plot.html" style="background-image:none;">plot()<\/a><\/code>/g' anintro.html
sed -i '120,$s/lapply()/<a href="..\/..\/base\/html\/lapply.html" style="background-image:none;">lapply()<\/a>/g' anintro.html
sed -i '120,$s/do.call()/<a href="..\/..\/base\/html\/do.call.html" style="background-image:none;">do.call()<\/a>/g' anintro.html
sed -i '120,$s/rbind()/<a href="..\/..\/base\/html\/cbind.html" style="background-image:none;">rbind()<\/a>/g' anintro.html
sed -i '120,$s/matplot()/<a href="..\/..\/graphics\/html\/matplot.html" style="background-image:none;">matplot()<\/a>/g' anintro.html
sed -i '120,$s/unlist()/<a href="..\/..\/base\/html\/unlist.html" style="background-image:none;">unlist()<\/a>/g' anintro.html
sed -i '120,$s/heat.colors()/<a href="..\/..\/grDevices\/html\/palettes.html" style="background-image:none;">heat.colors()<\/a>/g' anintro.html
sed -i '120,$s/read.csv()/<a href="..\/..\/utils\/html\/read.table.html" style="background-image:none;">read.csv()<\/a>/g' anintro.html
sed -i '120,$s/seq()/<a href="..\/..\/base\/html\/seq.html" style="background-image:none;">seq()<\/a>/g' anintro.html
sed -i '120,$s/substitute()/<a href="..\/..\/base\/html\/substitute.html" style="background-image:none;">substitute()<\/a>/g' anintro.html
sed -i '120,$s/for()/<a href="..\/..\/base\/html\/Control.html" style="background-image:none;">for()<\/a>/g' anintro.html
sed -i '120,$s/browseURL()/<a href="..\/..\/utils\/html\/browseURL.html" style="background-image:none;">browseURL()<\/a>/g' anintro.html
