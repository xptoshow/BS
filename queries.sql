-- ============== Recupera as guias semelhantes que são de origem do sistema SSCF e são específicas do movimento SADT.


-- 1 RECUPERA GUIAS DE ORIGEM SSCF

WITH itens_cobrados_temp AS (
    SELECT
        to_char(SUM(guia_rec_glosa_item.cseq_item) || '-' -- somatorio dos itens
                || to_char(SUM(guia_rec_glosa_item.vglosa_proce_item_asstn)) || '-' -- somatorio dos valores cobrados por item de recurso
                || to_char(SUM(cpb.CREDE)) || '-' -- somatorio das redes
                || to_char(SUM(guia_rec_glosa_item.CMOTVO_GLOSA_PROCE)) -- somatorio das glosas
                ) id_itens_guia,
        COUNT(guia_rec_glosa_item.CSEQ_GUIA_REC_GLOSA_ITEM) QTD_ITENS,
        guia_rec_glosa.cseq_guia_rec_glosa
    FROM
          scam.guia_rec_glosa_item
   INNER JOIN scam.guia_rec_glosa ON guia_rec_glosa_item.cseq_guia_rec_glosa = guia_rec_glosa.cseq_guia_rec_glosa
   INNER JOIN scam.CONVENIO_PRESTADORA cp ON cp.seq_prestadora_servico = guia_rec_glosa.NSEQ_PRETR_SERVC AND cp.seq_convenio = guia_rec_glosa.CSEQ_CONVE
   INNER JOIN scam.CONFG_PLANO_BNEFC cpb ON guia_rec_glosa.CSEQ_CONFG_PLANO_BNEFC = cpb.CINTRN_CONFG_PLANO_BNEFC
    WHERE 0=0
        AND NOT EXISTS (SELECT 1 FROM scam.NOTA_PRESTADORA np WHERE to_char(np.NID_GUIA_OPER) = to_char(guia_rec_glosa.CID_GUIA_OPER))
    AND cp.tip_movimento in ('SADT', 'CMED')
         AND guia_rec_glosa.DINCL_REG BETWEEN to_date('01/06/2024','DD/MM/YYYY') AND to_date('01/10/2024','DD/MM/YYYY')
    GROUP BY
        guia_rec_glosa.cseq_guia_rec_glosa
)
SELECT
    grg_a.cid_guia_oper,
    grg_b.cid_guia_oper,
itens_cobrados_a.id_itens_guia
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
--GROUP BY itens_cobrados_a.id_itens_guia
ORDER BY itens_cobrados_a.id_itens_guia;



-- ============== Recupera as guias semelhantes do movimento HP

-- 2 RECUPERA GUIAS DE HP 

WITH itens_cobrados_temp AS (
    SELECT
        to_char(SUM(guia_rec_glosa_item.cseq_item) || '-'
                || to_char(SUM(guia_rec_glosa_item.vglosa_proce_item_asstn)) || '-'
                || to_char(SUM(npi.VLR_TOTAL_REALIZADO)) || '-'
                || to_char(SUM(npiv.VLR_TOTAL_APROVADO)) || '-'
                || to_char(SUM(cpb.CREDE)) || '-'
                || to_char(SUM(mgm.COD_MENSAGEM_INTERNO)) || '-'
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
        cp.tip_movimento = 'HP'
        AND guia_rec_glosa.DINCL_REG BETWEEN to_date('01/06/2024','DD/MM/YYYY') AND to_date('01/10/2024','DD/MM/YYYY')
        AND mgm.COD_MENSAGEM_TISS NOT in(3052)
    GROUP BY
        guia_rec_glosa.cseq_guia_rec_glosa
)
SELECT
    grg_a.cid_guia_oper,
    grg_b.cid_guia_oper,
itens_cobrados_a.id_itens_guia
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
--GROUP BY itens_cobrados_a.id_itens_guia
ORDER BY itens_cobrados_a.id_itens_guia;


-- ============== Recupera as guias semelhantes do movimento HM


-- 3 RECUPERA GUIAS DE HM

WITH itens_cobrados_temp AS (
    SELECT
        to_char(SUM(guia_rec_glosa_item.cseq_item) || '-'
                || to_char(SUM(guia_rec_glosa_item.vglosa_proce_item_asstn)) || '-'
                || to_char(SUM(npi.VLR_TOTAL_REALIZADO)) || '-'
                || to_char(SUM(npiv.VLR_TOTAL_APROVADO)) || '-'
                || to_char(SUM(cpb.CREDE)) || '-'
                || to_char(SUM(mgm.COD_MENSAGEM_INTERNO)) || '-'
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
        cp.tip_movimento = 'HM'
		AND guia_rec_glosa.DINCL_REG BETWEEN to_date('01/06/2024','DD/MM/YYYY') AND to_date('01/10/2024','DD/MM/YYYY')
        AND mgm.COD_MENSAGEM_TISS NOT in(3052)
    GROUP BY
        guia_rec_glosa.cseq_guia_rec_glosa
)
SELECT
    grg_a.cid_guia_oper,
    grg_b.cid_guia_oper,
itens_cobrados_a.id_itens_guia
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
--GROUP BY itens_cobrados_a.id_itens_guia
ORDER BY itens_cobrados_a.id_itens_guia;



-- ============== Recupera as guias semelhantes do movimento SADT


-- 4 RECUPERA GUIAS DE SADT

WITH itens_cobrados_temp AS (
    SELECT
        to_char(SUM(guia_rec_glosa_item.cseq_item) || '-'
                || to_char(SUM(guia_rec_glosa_item.vglosa_proce_item_asstn)) || '-'
                || to_char(SUM(npi.VLR_TOTAL_REALIZADO)) || '-'
                || to_char(SUM(npiv.VLR_TOTAL_APROVADO)) || '-'
                || to_char(SUM(cpb.CREDE)) || '-'
                || to_char(SUM(mgm.COD_MENSAGEM_INTERNO)) || '-'
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
        AND guia_rec_glosa.DINCL_REG BETWEEN to_date('01/06/2024','DD/MM/YYYY') AND to_date('01/10/2024','DD/MM/YYYY')
        AND mgm.COD_MENSAGEM_TISS NOT in(3052)
    GROUP BY
        guia_rec_glosa.cseq_guia_rec_glosa
)
SELECT
    grg_a.cid_guia_oper,
    grg_b.cid_guia_oper,
itens_cobrados_a.id_itens_guia
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
--GROUP BY itens_cobrados_a.id_itens_guia
ORDER BY itens_cobrados_a.id_itens_guia;

-- ============== Recupera as guias semelhantes do movimento CMED


-- 5 RECUPERA GUIAS DE CMED

WITH itens_cobrados_temp AS (
    SELECT
        to_char(SUM(guia_rec_glosa_item.cseq_item) || '-'
                || to_char(SUM(guia_rec_glosa_item.vglosa_proce_item_asstn)) || '-'
                || to_char(SUM(npi.VLR_TOTAL_REALIZADO)) || '-'
                || to_char(SUM(npiv.VLR_TOTAL_APROVADO)) || '-'
                || to_char(SUM(cpb.CREDE)) || '-'
                || to_char(SUM(mgm.COD_MENSAGEM_INTERNO)) || '-'
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
        cp.tip_movimento = 'CMED'
        AND guia_rec_glosa.DINCL_REG BETWEEN to_date('01/06/2024','DD/MM/YYYY') AND to_date('01/10/2024','DD/MM/YYYY')
        AND mgm.COD_MENSAGEM_TISS NOT in(3052)
    GROUP BY
        guia_rec_glosa.cseq_guia_rec_glosa
)
SELECT
    grg_a.cid_guia_oper,
    grg_b.cid_guia_oper,
itens_cobrados_a.id_itens_guia
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
--GROUP BY itens_cobrados_a.id_itens_guia
ORDER BY itens_cobrados_a.id_itens_guia;

