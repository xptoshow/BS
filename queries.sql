WITH itens_cobrados_temp AS (
    SELECT
        to_char(SUM(guia_rec_glosa_item.cseq_item)
                || to_char(SUM(guia_rec_glosa_item.vglosa_proce_item_asstn))
                || to_char(SUM(npi.VLR_TOTAL_REALIZADO))
                || to_char(SUM(npiv.VLR_TOTAL_APROVADO))
                || to_char(SUM(cpb.CREDE))
                || to_char(SUM(mgm.COD_MENSAGEM_INTERNO))
                || to_char(SUM(mgm.COD_MENSAGEM_TISS))
                ) id_itens_guia,
        COUNT(guia_rec_glosa_item.CSEQ_GUIA_REC_GLOSA_ITEM) QTD_ITENS,
        guia_rec_glosa.cseq_guia_rec_glosa
    FROM
          scam.guia_rec_glosa_item
   INNER JOIN scam.guia_rec_glosa ON guia_rec_glosa_item.cseq_guia_rec_glosa = guia_rec_glosa.cseq_guia_rec_glosa
   INNER JOIN scam.CONVENIO_PRESTADORA cp ON cp.seq_prestadora_servico = guia_rec_glosa.NSEQ_PRETR_SERVC AND cp.seq_convenio = guia_rec_glosa.CSEQ_CONVE
   INNER JOIN scam.NOTA_PRESTADORA_ITEM npi ON npi.seq_nota_item = guia_rec_glosa_item.CSEQ_ITEM_NOTA_PRETR
   INNER JOIN scam.NOTA_PRESTADORA_ITEM_VALORADO npiv ON npi.seq_nota_item = npiv.seq_nota_item
   INNER JOIN scam.CONFG_PLANO_BNEFC cpb ON guia_rec_glosa.CSEQ_CONFG_PLANO_BNEFC = cpb.CINTRN_CONFG_PLANO_BNEFC
   INNER JOIN scam.MOTIVO_GLOSA_TRANSACAO mgt ON npi.SEQ_NOTA_ITEM = mgt.SEQ_NOTA_ITEM
   INNER JOIN scam.MOTIVO_GLOSA_MENSAGEM mgm ON mgt.SEQ_MGLOSA_MENSAGEM = mgm.SEQ_MGLOSA_MENSAGEM
    WHERE
        cp.tip_movimento = 'SADT'
        AND guia_rec_glosa.DINCL_REG > to_date('01/10/2010','DD/MM/YYYY')
    GROUP BY
        guia_rec_glosa.cseq_guia_rec_glosa
)
SELECT distinct(GUIA_OPERADORA) GUIA_OPERADORA,
  ID_GUIA_SEMELHANTE
FROM (
SELECT
   grg_a.cid_guia_oper GUIA_OPERADORA,
   grg_b.cid_guia_oper,
itens_cobrados_a.id_itens_guia ID_GUIA_SEMELHANTE
   --COUNT(itens_cobrados_a.id_itens_guia) QTD
FROM
scam.rec_glosa rg_a,    
scam.guia_rec_glosa grg_a,
itens_cobrados_temp itens_cobrados_a,
scam.rec_glosa rg_b,
   scam.guia_rec_glosa grg_b,
   itens_cobrados_temp itens_cobrados_b
WHERE 1 = 1
and grg_a.cseq_guia_rec_glosa <> grg_b.cseq_guia_rec_glosa
and rg_a.cseq_rec_glosa = grg_a.cseq_rec_Glosa
and rg_b.cseq_rec_glosa = grg_b.cseq_rec_glosa
and rg_a.NSEQ_PRETR_SERVC = rg_b.NSEQ_PRETR_SERVC -- mesmo referenciado
and grg_a.CSEQ_BNEFC <> grg_b.CSEQ_BNEFC --beneficiarios diferentes
and itens_cobrados_a.cseq_guia_rec_glosa = grg_a.cseq_guia_rec_glosa
and itens_cobrados_b.cseq_guia_rec_glosa = grg_b.cseq_guia_rec_glosa
and itens_cobrados_a.id_itens_guia = itens_cobrados_b.id_itens_guia -- mesmo token de itens;
AND itens_cobrados_a.QTD_ITENS = itens_cobrados_b.QTD_ITENS
);
